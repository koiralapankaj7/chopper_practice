import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'built_post.g.dart';

/// You now know almost all the things Chopper has to offer which you'll need on a daily basis. Sending requests, obtaining responses, adding interceptors... There's only one thing missing which will plug a hole in a clean coder's heart - type safety.
///
/// JSON itself is not typesafe, we'll have to live with it. However, we can make our code a lot more readable and less error prone if we ditch dynamic data for a real data type. Chopper offers an amazing way to convert request and response data with the help of a library of  your own choice. Our choice for for this tutorial will be built_value.
///
/// Built Value is arguably the best choice when you want to create immutable data classes (with all the bells and whistles like copying and value equality) AND on top of that, it has a first-class JSON serialization support.
///
/// We're interested in all the fields except userId. Let's now create a BuiltPost class which will hold all of this data. Similar to Chopper itself, Built Value also utilizes source generation, so we'll create a new file built_post.dart and the actual implementation will be inside a generated built_post.g.dart file. To keep things organized, we'll even put all this into a new model folder.

abstract class BuiltPost implements Built<BuiltPost, BuiltPostBuilder> {
  // IDs are set in the back-end.
  // In a POST request, BuiltPost's ID will be null.
  // Only BuiltPosts obtained through a GET request will have an ID.

  /// [1.] Fields are get-only properties - data will actually be stored in the generated class.
  /// [2.] The default constructor is private, there's a factory taking in a Builder instead.
  /// [a.] Fields' values are set through the Builder.
  /// [3.] Specifying a serializer property generates a class _$BuiltPostSerializer, which is what we'll use to convert that ugly dynamic data into our beautiful BuiltPost data class.
  ///
  /// While posting data to the api we wont change id as, changing id is handled through backend. In that case we need to set id null that is why we are annotating @nullable.
  @nullable
  int get id;
  String get title;
  String get body;

  // Private default constructor
  BuiltPost._();

  /// Default constructor is private so that we cannot instanciated [BuildPost] directly without utilizing the [BuiltPostBuilder].
  factory BuiltPost([updates(BuiltPostBuilder b)]) = _$BuiltPost;

  /// [serializer] is responsible for taking the data inside [BuiltPost] and serializing it into a map which than will be later on searilized into json string which than will be  transfer to the server inside a request. Also the serializer will be responsible for deserializing all of that nasty dynamic data into beautiful type safe [BuiltPost].
  static Serializer<BuiltPost> get serializer => _$builtPostSerializer;
}
