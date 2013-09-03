BBSignal
========

Alternative event system

Simple, small and fast event system - Signal.
Pretty simple API.
How to use:

1) Need to create signal and then add listener.
All listeners must have parameter - BBSignal.

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

2) Need to remove invoked listener and stop dispatching of signal.

```actionscript3
private function listener(p_signal:BBSignal):void
{
      p_signal.removeCurrentListener();
      p_signal.stopDispatching();
}

```

3) Need to dispatch with parameters.

```actionscript3
myClass.onReadySignal.dispatch("Hello");

private function listener(p_signal:BBSignal):void
{
      var string:String = p_signal.params as String;
}
```

4) Need to remove signal
```actionscript3
myClass.onReadySignal.dispose();
```

5) Need to clear pool of signals
```actionscript3
BBSignal.rid();
```

There is possible to get dispatcher from signal instance - object which contains current signal instance.
There is 'once' parameter which gives possibilities mark whole signal as 'once' or specify listener.
Once param mean that listeners/listener will invoke only one time and after invocation will remove from signal.