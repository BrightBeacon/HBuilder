document.addEventListener( "plusready",  function()
{
	var _BARCODE = 'iBeacon',
	B = window.plus.bridge;
	var iBeacon =
	{
		isRangingAvailable : function (successCallback, errorCallback )
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);

			return B.exec(_BARCODE, "isRangingAvailable", [callbackID]);
		},
		requestAlwaysAuthorization : function (successCallback, errorCallback )
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);

			return B.exec(_BARCODE, "requestAlwaysAuthorization", [callbackID]);
		},
		requestWhenInUseAuthorization : function (successCallback, errorCallback )
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);

			return B.exec(_BARCODE, "requestWhenInUseAuthorization", [callbackID]);
		},
		monitoredRegions : function (successCallback, errorCallback )
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);

			return B.exec(_BARCODE, "monitoredRegions", [callbackID]);
		},
		rangedRegions : function (successCallback, errorCallback )
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "rangedRegions", [callbackID]);
		},
		startRangingBeaconsInRegion : function (region, successCallback, errorCallback )
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);

			return B.exec(_BARCODE, "startRangingBeaconsInRegion", [callbackID, region]);
		},
		startMonitoringForRegion : function (region, successCallback, errorCallback )
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.exec(_BARCODE, "startMonitoringForRegion", [callbackID, region]);
		},
		stopMonitoringForRegion : function (region)
		{
			return B.execSync(_BARCODE, "stopMonitoringForRegion", ["",region]);
		},
		stopRangingBeaconsInRegion : function (region)
		{
			return B.execSync(_BARCODE, "stopRangingBeaconsInRegion", ["",region]);
		},
		requestStateForRegion : function (region, successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "requestStateForRegion", [callbackID,region]);
		},
		registerLocalNotification : function (successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "registerLocalNotification", [callbackID]);
		},
		sendLocalNotification : function (notify,successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "sendLocalNotification", [callbackID,notify]);
		},
		onAppStartByLocalNotification : function (successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "onAppStartByLocalNotification", [callbackID]);
		},
		startAdvertising : function (region, successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "startAdvertising", [callbackID,region]);
		},
		stopAdvertising : function ()
		{
			return B.execSync(_BARCODE, "stopAdvertising", []);
		},
		scanForPeripheralsWithServices : function (arr, successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "scanForPeripheralsWithServices", [callbackID,arr]);
		},
		stopScan : function ()
		{
			return B.execSync(_BARCODE, "stopScan", []);
		},
		connectPeripheral : function (peripheral, successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "connectPeripheral", [callbackID,peripheral]);
		},
		disconnectPeripheral : function (peripheral, successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "disconnectPeripheral", [callbackID,peripheral]);
		},
		readPeripheralCharacteristic : function (p,c, successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "readPeripheralCharacteristic", [callbackID,p,c]);
		},
		writePeripheralCharacteristic : function (p, c, d, r, successCallback, errorCallback)
		{
			var success = typeof successCallback !== 'function' ? null : function(args)
			{
				successCallback(args);
			},
			fail = typeof errorCallback !== 'function' ? null : function(code)
			{
				errorCallback(code);
			};
			callbackID = B.callbackId(success, fail);
			return B.execSync(_BARCODE, "writePeripheralCharacteristic", [callbackID,p, c, d, r]);
		}
	};
	window.plus.iBeacon = iBeacon;



}, true );
