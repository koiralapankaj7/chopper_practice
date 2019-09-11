import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'built_post.dart';

part 'serializers.g.dart';

/// [Adding BuiltPost to global serializers]
///
/// Yes, once we generate code, we'll have a serializer for BuiltPost classes. It turns out though that this is not enough! There's an entire ecosystem of other serializers for types like integer, String, bool and other primitives.
///
/// To successfully serialize and deserialize BuiltPost, our app will have to use it in conjunction with other serializers. We can accomplish this by adding BuiltPost's serializer to the list of all serializers built_value has to offer.
///
///
/// Make sure you add the StandardJsonPlugin whenever you want to use the generated JSON with a RESTful API. By default, BuiltValue's JSON output aren't key-value pairs, but instead a list containing [key1, value1, key2, value2, ...]. This is not what most of the APIs expect.
///
@SerializersFor(const [BuiltPost])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
