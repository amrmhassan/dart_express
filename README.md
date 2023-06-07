# The final solution to HttpServers with dart  

`dart_express` handles (Advanced Routing, HttpServers, websites hosting, static files hosting and much more...)

## Features

1. Allow adding routing system
1. Host of static folders or websites
1. Pre programmed code for some utils like(Html response, json response)

## Tutorial  

### Routing ( Request Processors )
`dart_express` consist of different layers which are a type of `RequestProcessor` which mean they can handle incoming requests.

1. Handler: is the final stage in the life of the request in the server, handlers must return a response to the client ( API consumer ), a handler can have a local middleware that will only work for this handler, 
Handler needs a pathTemplate a method and a processor function.

1. Middlewares: is a set of functions that live between the handler and the client to do some authentication or verification on the request, middlewares can return a request to let the request pass to the next middleware or handler or they can return a response to close prevent the request from passing to the next entity in the pipeline, 
middleware can be added to a single handler, router, full pipeline or the every single request that comes to the server which are called global middlewares.

3. Router: router is the parent of handlers, you can add multiple handlers to the router and the router is responsible for choosing the right handler to execute,  
you can also add middlewares to the router that will be executed only in this router.

1. Pipeline: pipelines are the master of all the previous entities, you can add multiple routers, individual handlers to the pipeline and it will chose the right middlewares and the right handler to run for each incoming request.

1. Cascade: cascade is just a way of adding multiple pipelines to the server if you have different types of apps that running on the same server you can just gather them in a single cascade. 

### Server ( the actual server the receive requests )
`ServerHolder` is a class that handles creating servers and closing them 
it needs a request processor from above which will handle running the right handler and the right set of middlewares, 
you can run multiple servers for the same server holder.

### RequestProcessor parameters
1. pathTemplate: is the path template that would be compared with the incoming request path it should be unique for each handler  
and it follows the following formula
```
e.g: /login  
     /register  
     /users/list  
     /users/<user_id>/getData  
     /users/<users_id>/deleteUser  
     /files/*<file_path> 
 ```

- The normal pathTemplate is like /login , `/register` or `/users/list`
if any request has the same path it the corresponding handler will be chosen to run
- The pathTemplate with pathArg like `/users/<user_id>/getData`  , `/users/<user_id>/deleteUser`  
and any request with paths like /users/anyUserId/deleteUser this handler will work
and it will have access to the pathArgs in the form of `{'user_id':'anyUserId'}`
- The final pathTemplate example is for paths that have pathArgs with that contains multiple slashes /
for example, any request with paths like /files/path/to/file will work for be directed to the handler with path template `/files/*<file_path>` and will provide pathArgs map as `{'file_path':'path/to/file'}`  
you can only have one complex key like *<file_path> at the end or it will consider all the following path to be a value of the key.


## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
