document.addEventListener("plusready", function() {
	var _BARCODE = 'ibeacon',
		B = window.plus.bridge;
	var ibeacon = {
		//  开启蓝牙，仅android可用
		openBluetoothAdapter: function(params) {
			//alert("openBluetoothAdapter");
			if(params == undefined) {
				return B.exec(_BARCODE, "openBluetoothAdapter", []);
			}
			var complete = function(args) {
				if(typeof params.complete === 'function') params.complete(args);
			};
			var success = typeof params.success !== 'function' ? complete : function(args) {
					params.success(args);
					complete(args);
				},
				fail = typeof params.fail !== 'function' ? complete : function(args) {
					params.fail(args);
					complete(args);
				};
			var callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "openBluetoothAdapter", [callbackID]);
		},
		//  关闭蓝牙，仅android可用
		closeBluetoothAdapter: function(params) {
			//alert("closeBluetoothAdapter");
			if(params == undefined) {
				return B.exec(_BARCODE, "closeBluetoothAdapter", []);
			}
			var complete = function(args) {
				if(typeof params.complete === 'function') params.complete(args);
			};
			var success = typeof params.success !== 'function' ? complete : function(args) {
					params.success(args);
					complete(args);
				},
				fail = typeof params.fail !== 'function' ? complete : function(args) {
					params.fail(args);
					complete(args);
				};
			var callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "closeBluetoothAdapter", [callbackID]);
		},
		//获取蓝牙状态
		getBluetoothAdapterState: function(params) {
			//alert("getBluetoothAdapterState");
			if(params == undefined) {
				return B.exec(_BARCODE, "getBluetoothAdapterState", []);
			}
			var complete = function(args) {
				if(typeof params.complete === 'function') params.complete(args);
			};
			var success = typeof params.success !== 'function' ? complete : function(args) {
					params.success(args);
					complete(args);
				},
				fail = typeof params.fail !== 'function' ? complete : function(args) {
					params.fail(args);
					complete(args);
				};
			var callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "getBluetoothAdapterState", [callbackID]);
		},

		onBluetoothAdapterStateChange: function(params) {
			if(params == undefined) {
				return B.exec(_BARCODE, "onBluetoothAdapterStateChange", []);
			}
			var complete = function(args) {
				if(typeof params.complete === 'function') params.complete(args);
			};
			var success = typeof params.success !== 'function' ? complete : function(args) {
					params.success(args);
					complete(args);
				},
				fail = typeof params.fail !== 'function' ? complete : function(args) {
					params.fail(args);
					complete(args);
				};
			var callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "onBluetoothAdapterStateChange", [callbackID]);
		},
		startBeaconDiscovery: function(params) {
			if(params == undefined) {
				return B.exec(_BARCODE, "startBeaconDiscovery", []);
			}
			var complete = function(args) {
				if(typeof params.complete === 'function') params.complete(args);
			};
			var success = typeof params.success !== 'function' ? complete : function(args) {
					params.success(args);
					complete(args);
				},
				fail = typeof params.fail !== 'function' ? complete : function(args) {
					params.fail(args);
					complete(args);
				};
			var callbackID = B.callbackId(success, fail);
			return B.exec(_BARCODE, "startBeaconDiscovery", [callbackID, params.uuids]);
		},
		stopBeaconDiscovery: function(params) {
			if(params == undefined) {
				return B.exec(_BARCODE, "stopBeaconDiscovery", []);
			}
			var complete = function(args) {
				if(typeof params.complete === 'function') params.complete(args);
			};
			var success = typeof params.success !== 'function' ? complete : function(args) {
					params.success(args);
					complete(args);
				},
				fail = typeof params.fail !== 'function' ? complete : function(args) {
					params.fail(args);
					complete(args);
				};
			var callbackID = B.callbackId(success, fail);
			return B.exec(_BARCODE, "stopBeaconDiscovery", [callbackID]);
		},
		getBeacons: function(params) {
			if(params == undefined) {
				return B.exec(_BARCODE, "getBeacons", []);
			}
			var complete = function(args) {
				if(typeof params.complete === 'function') params.complete(args);
			};
			var success = typeof params.success !== 'function' ? complete : function(args) {
					params.success(args);
					complete(args);
				},
				fail = typeof params.fail !== 'function' ? complete : function(args) {
					params.fail(args);
					complete(args);
				};
			var callbackID = B.callbackId(success, fail);

			return B.exec(_BARCODE, "getBeacons", [callbackID]);
		},
		onBeaconUpdate: function(success) {
			if(success == undefined) {
				return B.exec(_BARCODE, "onBeaconUpdate", []);
			}
			var callbackID = B.callbackId(success);
			return B.exec(_BARCODE, "onBeaconUpdate", [callbackID]);
		},
		onBeaconServiceChange: function(params) {
			if(params == undefined) {
				return B.exec(_BARCODE, "onBeaconServiceChange", []);
			}
			var complete = function(args) {
				if(typeof params.complete === 'function') params.complete(args);
			};
			var success = typeof params.success !== 'function' ? complete : function(args) {
					params.success(args);
					complete(args);
				},
				fail = typeof params.fail !== 'function' ? complete : function(args) {
					params.fail(args);
					complete(args);
				};
			var callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "onBeaconServiceChange", [callbackID]);
		}
	};
	window.plus.ibeacon = ibeacon;

}, true);
