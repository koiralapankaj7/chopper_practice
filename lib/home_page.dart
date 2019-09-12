import 'dart:convert';
import 'package:chopper_practice/data/post_api_service.dart';
import 'package:chopper_practice/model/built_post.dart';
import 'package:chopper_practice/single_post_page.dart';
import 'package:flutter/material.dart';
import 'package:chopper/chopper.dart';
import 'package:provider/provider.dart';
import 'package:built_collection/built_collection.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chopper Blog'),
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Use BuiltPost even for POST requests
          final newPost = BuiltPost(
            (b) => b
              // id is null - it gets assigned in the backend
              ..title = 'New Title'
              ..body = 'New body',
          );

          // The JSONPlaceholder API always responds with whatever was passed in the POST request
          final response = await Provider.of<PostApiService>(context).postPost(newPost);
          // We cannot really add any new posts using the placeholder API,
          // so just print the response to the console
          print(response.body);
        },
      ),
    );
  }

  FutureBuilder<Response<BuiltList<BuiltPost>>> _buildBody(BuildContext context) {
    // FutureBuilder is perfect for easily building UI when awaiting a Future
    // Response is the type currently returned by all the methods of PostApiService
    return FutureBuilder<Response<BuiltList<BuiltPost>>>(
      // In real apps, use some sort of state management (BLoC is cool)
      // to prevent duplicate requests when the UI rebuilds
      future: Provider.of<PostApiService>(context).getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          /// Exceptions thrown by the Future are stored inside the "error" field of the AsyncSnapshot
          ///
          /// After adding a MobileDataInterceptor instance to the list of interceptors, the exception will be thrown. Because of the way we've set up the app in the previous part, this exception will not crash the app - that's because we're using a FutureBuilder widget which kind of automatically handles exceptions.Still, we should show some message to the user to tell him what's going on.
          /// In this example app, we will display a Text widget to keep things simple.
          ///
          /// By the way, if the user is not connected to the Internet at all, HTTP package (which the Chopper uses) will throw its own exception and its message will be displayed in the Text widget as well.
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                textScaleFactor: 1.3,
              ),
            );
          }

          /// Snapshot's data is the Response
          /// You can see there's no type safety here (only List<dynamic>)
          // final List posts = json.decode(snapshot.data.bodyString);
          // return _buildPosts(context, posts);
          //* Body of the response is now type-safe and of type BuiltList<BuiltPost>.
          final posts = snapshot.data.body;
          return _buildPosts(context, posts);
        } else {
          // Show a loading indicator while waiting for the posts
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  ListView _buildPosts(BuildContext context, BuiltList<BuiltPost> posts) {
    return ListView.builder(
      itemCount: posts.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          child: ListTile(
            title: Text(
              posts[index].title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(posts[index].body),
            onTap: () => _navigateToPost(context, posts[index].id),
          ),
        );
      },
    );
  }

  void _navigateToPost(BuildContext context, int id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SinglePostPage(postId: id),
      ),
    );
  }

  //
  //
}
