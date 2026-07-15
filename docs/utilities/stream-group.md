# StreamGroup

`StreamGroup` merges multiple streams into a single output stream, emitting events as soon as any of the input streams emit them.

## Why use StreamGroup?

When you are listening to multiple event sources that trigger the same logical action (e.g., both a button tap and a keyboard shortcut), you don't want to manage multiple subscriptions. `StreamGroup` consolidates them so you only need to listen to one stream.

## Example

```dart
import 'dart:async';
import 'package:daxle/daxle.dart';

void main() async {
  final controllerA = StreamController<String>();
  final controllerB = StreamController<String>();

  final group = StreamGroup<String>();
  group.add(controllerA.stream);
  group.add(controllerB.stream);

  // Close the group once all streams are added
  group.close();

  // Listen to the unified stream
  group.stream.listen(print);

  controllerA.add('Event from A');
  controllerB.add('Event from B');
}
```

## When to use it
- **Unified Event Handling:** Merging various UI inputs into a single action stream.
- **Dynamic Sources:** Merging streams from dynamic sources (e.g., chat messages from different rooms) into a unified feed.
