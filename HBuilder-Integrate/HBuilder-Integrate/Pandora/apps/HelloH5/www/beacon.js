document.addEventListener("plusready", function() {
	var _BARCODE = 'beacon',
		B = window.plus.bridge;
	var beacon = {
		startBeaconDiscovery: function(params) {
            if(params == undefined) {
                return B.exec(_BARCODE, "startBeaconDiscovery",[]);
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
               return B.exec(_BARCODE, "stopBeaconDiscovery",[]);
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
                return B.exec(_BARCODE, "getBeacons",[]);
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
		onBeaconUpdate: function(params) {
            if(params == undefined) {
                return B.exec(_BARCODE, "onBeaconUpdate",[]);
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

			return B.exec(_BARCODE, "onBeaconUpdate", [callbackID]);
		},
		onBeaconServiceChange: function(params) {
            if(params == undefined) {
                 return B.exec(_BARCODE, "onBeaconServiceChange",[]);
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
	window.plus.beacon = beacon;

}, true);
