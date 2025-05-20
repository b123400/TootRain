# Obj-IRC –– main library
IRC protocol implementation, in *(almost)* pure Objective-C. Written by [@jndok](https://twitter.com/jndok) and [@H3xept](https://twitter.com/H3xept)

## A few warning words

Before you start dumping this lib into your code, please realize that is is purely an experimental thing I'm creating with a friend of mine. So expect bugs and random errors. We will continue to work on this, to make it better and better.

## Library usage
The `main` file gives you a good overview of the library methods and general usage. It is heavily commented and should provide a neat staring point.<br>Anyway, in this section I'll explain (roughly) how the library works. Much more details can be found in the upcoming wiki.

### 1.1 – Setting up the library
`Obj-IRC` requires no external dependencies, so just put an `#import` straight away and you're done. `Foundation` is needed, however.<br>The library operates in a separate thread, avoiding the interruption of your code. You can fetch the data retrieved by the thread using an handy set of ivars or/and by setting your own delegate method in the main file.

To set up the `ConnectionController`, do something like:
  
    ConnectionController* cc = [[ConnectionController alloc] init];

By default, every parameter for the connection is automatically set by `init`. You can see the various parameters in the `main` file.

### 1.2 – Connecting
To connect, once all the desired parameters have been set, just do something like:

    [cc connect];

The `connect` methods starts the library thread and begins to update the ivars and the delegate.

### 1.3 – After connecting
After connecting is done, you can still perform various commands on the `ConnectionController`, such as:

      [client join:@"#example"];
      [client leaveChannel:@"#example"];
