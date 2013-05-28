package bb.signals
{
	/**
	 * Класс реализует в себе альтернативу событийной модели именуемой сигнал.
	 * @author VirtualMaestro
	 */
	public class BBSignal
	{
		/**
		 * Ссылка на объект которому принадлежит данный сигнал.
		 */
		public var dispatcher:Object = null;
		public var onceSignal:Boolean = false;

		//
		private var _currentNode:NodeSignal = null;
		private var _nextNode:NodeSignal = null;
		private var _prevNode:NodeSignal = null;
		private var _head:NodeSignal = null;
		private var _tail:NodeSignal = null;
		private var _params:Object = null;
		private var _numListeners:int = 0;

		/**
		 * @param p_dispatcher - объект, которому принадлежит этот сигнал. (Обычно где обявляется сигнла, этот параметр принимает this)
		 * @param p_onceSignal - флаг указывает что все слушатели, не зависимо от того скаким параметром (once = true/false) они были добавлены,
		 *                       будут удалены после первой отправки сообщения.
		 */
		public function BBSignal(p_dispatcher:Object = null, p_onceSignal:Boolean = false)
		{
			dispatcher = p_dispatcher;
			onceSignal = p_onceSignal;
		}

		/**
		 * Добавляет слушатель в сигнал.
		 * @param p_listener - функция обработчик
		 * @param p_once - если true то этот слушатель будет вызван один раз после чего удален.
		 */
		public function add(p_listener:Function, p_once:Boolean = false):void
		{
			var node:NodeSignal = getNode();
			node.listener = p_listener;

			if (_tail == null) _head = node;
			else
		    {
			    _tail.next = node;
			    node.prev = _tail;
		    }

			_tail = node;
			node.once = p_once;
			_numListeners++;
		}

		/**
		 * Удаляет заданный слушатель.
		 */
		public function remove(p_listener:Function):void
		{
			if (_numListeners > 0)
			{
				var node:NodeSignal = _head;
				var curNode:NodeSignal;

				while(node)
				{
					curNode = node;
					node = node.next;

					if (curNode.listener == p_listener)
					{
						if (curNode == _nextNode) _nextNode = curNode.next;
						if (curNode == _prevNode) _prevNode = curNode.prev;

						unlink(curNode);
						break;
					}
				}
			}
		}

		/**
		 * Удаляет все слушатели.
		 */
		public function removeAllListeners():void
		{
			if (_numListeners > 0)
			{
				var node:NodeSignal = _head;
				var curNode:NodeSignal;

				while(node)
				{
					curNode = node;
					node = node.next;

					unlink(curNode);
				}

				_head = null;
				_tail = null;
				_numListeners = 0;

				stopDispatching();
			}
		}

		/**
		 * Удаляется текущий вызванный обработчик.
		 */
		public function removeCurrentListener():void
		{
			if (_currentNode) unlink(_currentNode);
			_currentNode = null;
		}

		/**
		 * Проверяет существует ли данный слушатель в этои сигнале.
		 */
		public function contains(p_listener:Function):Boolean
		{
			var node:NodeSignal = _head;
			while(node)
			{
				if (node.listener == p_listener) return true;
				node = node.next;
			}

			return false;
		}

		/**
		 * Посылает сигнал (сигнал посылается от первого до последнего).
		 */
		public function dispatch(parameters:Object = null):void
		{
			if (_numListeners > 0)
			{
				_params = parameters;
				var node:NodeSignal = _head;
				var once:Boolean = false;
				_currentNode = node;

				while (_currentNode)
				{
					node = node.next;
					_nextNode = node;

					once = _currentNode.once;
					_currentNode.listener(this);

					if (once)
					{
						if (_currentNode && !_currentNode.isDisposed) unlink(_currentNode);
					}

					_currentNode = _nextNode;
					node = _nextNode;
				}

				if (onceSignal) removeAllListeners();

				_params = null;
			}
		}

		/**
		 * Посылает сигнал (сигнал посылается от последнего к первому слушателю).
		 */
		public function dispatchReverse(parameters:Object = null):void
		{
			if (_numListeners > 0)
			{
				_params = parameters;
				var node:NodeSignal = _tail;
				var once:Boolean = false;
				_currentNode = node;

				while (_currentNode)
				{
					node = node.prev;
					_prevNode = node;

					once = _currentNode.once;
					_currentNode.listener(this);

					if (once)
					{
						if (_currentNode && !_currentNode.isDisposed) unlink(_currentNode);
					}

					_currentNode = _prevNode;
					node = _prevNode;
				}

				if (onceSignal) removeAllListeners();

				_params = null;
			}
		}

		/**
		 * Прекращает рассылку сигнала.
		 */
		public function stopDispatching():void
		{
			_currentNode = null;
			_nextNode = null;
			_prevNode = null;
		}

		/**
		 * Возвращает количество слушателей.
		 */
		public function get numListeners():int
		{
			return _numListeners;
		}

		/**
		 * Возвращает параметры, которые были переданы при диспатчинге.
		 */
		public function get params():Object
		{
			return _params;
		}

		/**
		 */
		private function unlink(p_node:NodeSignal):void
		{
			if (p_node == _head)
			{
				_head = _head.next;
				if (_head == null) _tail = null;
				else _head.prev = null;
			}
			else if (p_node == _tail)
			{
				_tail = _tail.prev;
				if (_tail == null) _head = null;
				else _tail.next = null;
			}
			else
			{
				var prevNode:NodeSignal = p_node.prev;
				var nextNode:NodeSignal = p_node.next;
				prevNode.next = nextNode;
				nextNode.prev = prevNode;
			}

			// Put node to pool
			putNode(p_node);

			_numListeners--;
		}

		/**
		 * При вызове данного метода сигнал будет очищен и добавлен в пул для переиспользования.
		 * Чтобы очистить пул от сигналов хранящихся там нужно вызвать статический метод rid.
		 */
		public function dispose():void
		{
			removeAllListeners();
			clearNodePool();
			_params = null;
			dispatcher = null;

			// Add signal to pool
			put(this);
		}

		/////////////////////////
		//  NODE'S POOL SYSTEM //
		/////////////////////////
		private var _headPool:NodeSignal = null;

		/**
		 */
		private function putNode(p_node:NodeSignal):void
		{
			p_node.prev = null;
			p_node.listener = null;
			p_node.isDisposed = true;

			if (_headPool) p_node.next = _headPool;
			else p_node.next = null;

			_headPool = p_node;
		}

		/**
		 */
		private function getNode():NodeSignal
		{
			var node:NodeSignal;
			if (_headPool)
			{
				node = _headPool;
				_headPool = _headPool.next;
				node.next = null;
				node.isDisposed = false;
			}
			else node = new NodeSignal();

			return node;
		}

		/**
		 */
		private function clearNodePool():void
		{
			if (_headPool)
			{
				var node:NodeSignal;
				while(_headPool)
				{
					node = _headPool;
					_headPool = _headPool.next;
					node.next = null;
					node.prev = null;
					node.listener = null;
				}
			}
		}

		///////////////////////////
		//  SIGNAL'S POOL SYSTEM //
		///////////////////////////

		/**
		 * Gets signal instance.
		 */
		static public function get(p_dispatcher:Object = null, p_onceSignal:Boolean = false):BBSignal
		{
			var signal:BBSignal = getSignal();
			signal.dispatcher = p_dispatcher;
			signal.onceSignal = p_onceSignal;

			return signal;
		}

		//
		static private var _pool:Array;
		static private var _available:int = 0;

		/**
		 * Put signal to pool.
		 */
		static private function put(p_signal:BBSignal):void
		{
			if (_pool == null) _pool = [];
			_pool[_available++] = p_signal;
		}

		/**
		 * Get signal instance from pool or creates one.
		 */
		static private function getSignal():BBSignal
		{
			var signal:BBSignal;

			if (_available > 0)
			{
				signal = _pool[--_available];
				_pool[_available] = null;
			}
			else signal = new BBSignal();

			return signal;
		}

		/**
		 * Removes pool of signals.
		 * Destroys all signal instance in pool.
		 */
		static public function rid():void
		{
			if (_pool)
			{
				for (var i:int = 0; i < _available; i++)
				{
					_pool[i] = null;
				}

				_pool.length = 0;
				_pool = null;
				_available = 0;
			}
		}
	}
}

/**
 */
internal class NodeSignal
{
	public var next:NodeSignal = null;
	public var prev:NodeSignal = null;
	public var listener:Function = null;
	public var once:Boolean = false;
	public var isDisposed:Boolean = false;
}