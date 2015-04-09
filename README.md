BBSignal
========

Alternative event system

Fast, lightweight and simple signal.

How to use:

1) Need to create signal and then add listener.
Each listener must takes as a parameter BBSignal.

```actionscript3
class SomeClass
{
      public var onReadySignal:BBSignal;
      
      public function SomeClass()
      {
            onReadySignal = BBSignal.get(this);  
      }
}
......

var myClass:SomeClass = new SomeClass();
myClass.onReadySignal.add(listener);

private function listener(p_signal:BBSignal):void
{

}
```

2) Need to remove handler from signal.

```actionscript3
onReadySignal.remove(listener);
```

3) Need to remove handler from itself and stop dispatching.

```actionscript3
private function listener(p_signal:BBSignal):void
{
      p_signal.removeCurrentListener();
      p_signal.stopDispatching();
}
```

4) Need to dispatch with parameters.

```actionscript3
myClass.onReadySignal.dispatch("Hello");

private function listener(p_signal:BBSignal):void
{
      var string:String = p_signal.params as String;
}
```

5) If need to know who is dispatcher.

```actionscript3
private function listener(p_signal:BBSignal):void
{
      p_signal.dispatcher;
}
```

6) Need to remove signal
```actionscript3
myClass.onReadySignal.dispose();
```

7) Need to clear pool of signals
```actionscript3
BBSignal.rid();
```

No one object is created/destroyed if it is not needed. Most of operations performs very fast.
There is 'once' parameter which gives possibilities mark whole signal as 'once' or specify listener.
Once param mean that listeners/listener will be invoked only one time and after invocation removed from signal.
