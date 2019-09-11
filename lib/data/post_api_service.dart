import 'package:chopper/chopper.dart';
import 'package:chopper_practice/data/mobile_data_interceptor.dart';

/// Inorder to make code generation possible we need to create part statement
///  Source code generation in Dart works by creating a new file which contains a "companion class".
/// In order for the source gen to know which file to generate and which files are "linked", you need to use the part keyword.
part 'post_api_service.chopper.dart';

/// This file will store post api service which will extend chopper service
/// Choppers works by genereting code which is the reason we made this class abastract
/// Actual implementation of this class will be inside generated class
///
/// In order to make this class actually work with chopper we need to mark  it with an anotation  of [@ChopperApi()] which takse base url
/// [baseUrl] is api url
///

@ChopperApi(baseUrl: '/posts')
abstract class PostApiService extends ChopperService {
  /// Function which get all posts from the api
  /// Only declaring function will not work we have to specify which http request we are sending. For that we will anotate function with request type.
  ///
  /// Query parameters are specified the same way as @Path
  /// but obviously with a @Query annotation
  @Get()
  Future<Response> getPosts();
  // Headers (e.g. for Authentication) can be added in the HTTP method constructor
  // or also as parameters of the Dart method itself.
  // @Get(headers: {'Constant-Header-Name': 'Header-Value'})
  // Future<Response> getPosts([
  // Parameter headers are suitable for ones which values need to change
  //   @Header('Changeable-Header-Name') String headerValue,
  // ]);

  /// This function will get single post from the api
  ///
  /// Id should be dynamically assignable so we have to place inside curly braces
  ///
  /// Decliring int parameter id doesnt assign value to path itself. We have to anotate by @Path() inorder ro receive and assign id to path url from the parameter
  ///
  /// Headers can be used in both [@Get()] anotation function as well as in dart function e.g [getPost()]. If header is of fixed nature use annotation function else use dart function.
  ///
  ///
  @Get(path: '/{id}')
  Future<Response> getPost(@Path('id') int id);

  /// Implimentation of Put, Patch and Delete request is same as Post request
  /// Post request required body
  ///
  /// Put & Patch requests are specified the same way - they must contain the @Body

  @Post()
  Future<Response> postPost(
    @Body() Map<String, dynamic> body,
  );

  /// [ChopperClient] is build on top of the default dart [http] client.
  ///
  /// What we need to do inorder to use the [PostApiService] to simplify our work with the jsonplaceholder api is to some how connected together with [ChopperClient] by passing the chopper client over to the generated classes constructor.
  ///
  /// Basically we need  to instantiated the chopper client. The best place and most elignent way to do this is directly inside PostApiService , inside static function called create() which will return PostApiService which is already setup with the client to get a with the generated class and all of that good setup.
  ///
  /// [baseUrl] is top level domain of the api and this is the best place to write url insted in [@ChopperApi()]. Different endpoints are going to be entered in [@ChopperApi()] annotation.
  ///
  /// In [services] we are going to pass services which is the generated class. This is just to let the chopper client know which kind of services is  gonna work with.
  ///
  /// This way by calling the static function [create()]  will return a fully setup and initialized PostApiService instance.
  static PostApiService create() {
    final client = ChopperClient(
      // The first part of the URL is now here
      baseUrl: 'https://jsonplaceholder.typicode.com',
      services: [
        // The generated implementation
        _$PostApiService(),
      ],
      // Converts data to & from JSON and adds the application/json header.
      converter: JsonConverter(),

      /// [Interceptor foundations ]:
      ///
      /// The nature of interceptors is that they run with every request or response performed on a ChopperClient. If you want to perform a client-wide operation, interceptors are just the right thing to employ.
      ///
      /// The word "client-wide" is important. In the previous part, you learned that Chopper has the concept of a ChopperService - it contains methods for making requests. One service is usually reserved for one endpoint (e.g. "/posts", "/comments") and usually there are multiple services per one ChopperClient (e.g. PostService + CommentService).
      ///
      /// Do you want to keep a statistic of how many times a certain URL has been called? Do you want to add headers to every request? Do you want to tell the user to switch to WiFi when he's about to download a large file? All of this is a job for an interceptor.
      ///
      /// As you've learned above, interceptors are applied to the whole ChopperClient. They will therefore be specified inside the client's constructor. Even though there are two types of interceptors - request & response, they are both added into one list parameter.

      interceptors: [
        // Both request & response interceptors go here

        /// [Built-in interceptors]
        /// Being an awesome library, Chopper comes bundled with a couple of useful interceptors.
        ///
        /// [1. HeadersInterceptor]
        /// One of these interceptors is a HeadersInterceptor which will add headers to all of the requests performed by the ChopperClient. Headers are a Map<String, String>. Add the folowing to the interceptors list on a client:
        HeadersInterceptor({'Cache-Control': 'no-cache'}),

        /// [2. HttpLoggingInterceptor]
        /// The other built-in interceptors are made for debugging purposes.
        ///
        /// HttpLoggingInterceptor is a very useful tool for finding out detailed information about requests and responses. Once you set it up, you'll see detailed logs such as this one:
        HttpLoggingInterceptor(),

        /// [3. CurlInterceptor]
        /// This is the last built-in one. If you're not very good with CURL and you'd like to see the CURL command for the request made by the app, add the following:
        ///
        /// Then, after making GET or POST requests through Chopper, you'll get it printed out in the console. Again, follow the above steps to enable logging with the logging package.
        CurlInterceptor(),

        /// [4. Custom interceptors]
        /// Creating your own interceptors to run custom logic before requests or after responses can be done in 2 ways:
        /// 1. Simple anonymous functions
        /// 2. Classes implementing RequestInterceptor or ResponseInterceptor
        ///
        /// [a. Anonymous functions]
        /// These are perfect for quick little interceptors which don't contain a lot of logic. Usually, it's better to use the second option - create a separate class. Otherwise you might end up with a messy codebase. As always, single responsibility principle (SRP) is king!
        ///
        /// If you'd rather trade in SRP for quickness, this is how you define anonymous interceptors. Again, all of this goes into the interceptors list of the ChopperClient.
        ///
        /// Request and response interceptors differ only in the type of their parameter.
        ///
        /// Interceptors have to always return a request/response. Otherwise, the next called interceptor or other Chopper code will receive a null request/response. And you know what happens with nulls... 😬
        (Request request) async {
          if (request.method == HttpMethod.Post) {
            chopperLogger.info('Performed a POST request');
          }
          return request;
        },
        (Response response) async {
          if (response.statusCode == 404) {
            chopperLogger.severe('404 NOT FOUND');
          }
          return response;
        },

        /// [b. Separate classes]
        /// What if you want to prevent the user from downloading large files unless he's on WiFi? That sounds like it will be the best to make a separate RequestInterceptor class for that. ResponseInterceptors are, of course, done in the same manner.
        ///
        /// Before implementing our MobileDataInterceptor, we need to add one package to the project.
        MobileDataInterceptor(),

        //
        //
      ],
    );

    // The generated class with the ChopperClient passed in
    return _$PostApiService(client);
  }
}
