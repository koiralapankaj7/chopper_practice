import 'package:chopper/chopper.dart';
import 'package:chopper_practice/model/serializers.dart';
import 'package:built_collection/built_collection.dart';

/// [BuiltValueConverter]
///
/// After all this setup comes the part of this tutorial you are the most interested in - how do you "connect" Chopper and BuiltValue to work together? By creating a BuiltValueConverter.
///
/// We won't have to build it from scratch though, as we will utilize the binary data to dynamic Map/List conversion which the default JsonConverter provides. Still, there's a lot of coding ahead! Let's first override convertRequest method as it's a lot less tricky than convertResponse.
///
/// Of course, we are building this code to work generically with all the classes implementing Built, not just the BuiltPost.
class BuiltValueConverter extends JsonConverter {
  //
  //
  /// [Request conversion]
  /// Request classes do not (yet) use generic type parameters for their bodies, hence they're dynamic. We know, however, that the body of a request will always be an instance of BuiltPost or some other Built class, should we add one. Before sending out the request, we have to serialize the BuiltPost body to a Map which will subsequently get converted to JSON by Chopper.
  ///
  /// You could also let BuiltValue determine the serializer's type itself by calling serializers.serialize(request.body) but that would bloat the request body by adding unnecessary type-related data to it.
  @override
  Request convertRequest(Request request) {
    return super.convertRequest(
      request.replace(
        // request.body is of type dynamic, but we know that it holds only BuiltValue classes (BuiltPost).
        // Before sending the request to the network, serialize it to a List/Map using a BuiltValue serializer.
        body: serializers.serializeWith(
          // Since convertRequest doesn't have a type parameter, Serializer's type will be determined at runtime
          serializers.serializerForType(request.body.runtimeType),
          request.body,
        ),
      ),
    );
  }

  /// [Response conversion]
  /// Converting dynamic responses which contain either a List of Maps or just a Map itself is a bit of a tougher task. We will have to differentiate between the cases of deserializing a List and a single Map. Also, what if we explicitly set a method in the ChopperService to return a Map? You know, we might not always want to use BuiltValue data classes...
  ///
  /// To accomplish all of this while keeping the code clean, we will separate the conversion and deserialization into multiple methods. Also, as opposed to convertRequest, convertResponse does have type parameters, so we won't have to determine anything at runtime.
  ///
  /// Before we add all of the code though, those type parameters require a brief explanation. The definition of convertResponse is the following:
  /// [Response<BodyType> convertResponse<BodyType, SingleItemType>]
  /// [BodyType] will be a BuiltValue class, in our case it's either [BuiltPost] or [BuiltList<BuiltPost>].
  /// If a body of the response contains only a single object, [BodyType] and [SingleItemType] will be identical.
  /// If the body contains a list of objects, Chopper will set the [SingleItemType] to be, well, the type which the list contains.
  @override
  Response<BodyType> convertResponse<BodyType, SingleItemType>(Response response) {
    // The response parameter contains raw binary JSON data by default.
    // Utilize the already written code which converts this data to a dynamic Map or a List of Maps.
    final Response dynamicResponse = super.convertResponse(response);
    // customBody can be either a BuiltList<SingleItemType> or just the SingleItemType (if there's no list).
    final BodyType customBody = _convertToCustomObject<SingleItemType>(dynamicResponse.body);

    // Return the original dynamicResponse with a no-longer-dynamic body type.
    return dynamicResponse.replace<BodyType>(body: customBody);
  }

  dynamic _convertToCustomObject<SingleItemType>(dynamic element) {
    // If the type which the response should hold is explicitly set to a dynamic Map,
    // there's nothing we can convert.
    if (element is SingleItemType) return element;

    if (element is List)
      return _deserializeListOf<SingleItemType>(element);
    else
      return _deserialize<SingleItemType>(element);
  }

  BuiltList<SingleItemType> _deserializeListOf<SingleItemType>(
    List dynamicList,
  ) {
    // Make a BuiltList holding individual custom objects
    return BuiltList<SingleItemType>(
      dynamicList.map((element) => _deserialize<SingleItemType>(element)),
    );
  }

  SingleItemType _deserialize<SingleItemType>(
    Map<String, dynamic> value,
  ) {
    // We have a type parameter for the BuiltValue type
    // which should be returned after deserialization.
    return serializers.deserializeWith<SingleItemType>(
      serializers.serializerForType(SingleItemType),
      value,
    );
  }
  //
  //
}
