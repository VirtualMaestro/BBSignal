BBSignal
========

Alternative event system
Simple, small and fast event system - Signal.

How to use:

1. Need to create signal and then add listener.
All listeners must have parameter - BBSignal.

```
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
