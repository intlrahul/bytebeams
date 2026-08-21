# bytebeams_api.api.DefaultApi

## Load the API package
```dart
import 'package:bytebeams_api/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getBootstrap**](DefaultApi.md#getbootstrap) | **GET** /bootstrap | Bootstrap the local fleet database
[**getHealth**](DefaultApi.md#gethealth) | **GET** /health | Check server availability
[**streamTelemetry**](DefaultApi.md#streamtelemetry) | **GET** /telemetry | Stream live telemetry deliveries


# **getBootstrap**
> BootstrapResponse getBootstrap()

Bootstrap the local fleet database

### Example
```dart
import 'package:bytebeams_api/api.dart';

final api = BytebeamsApi().getDefaultApi();

try {
    final response = api.getBootstrap();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getBootstrap: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BootstrapResponse**](BootstrapResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHealth**
> HealthResponse getHealth()

Check server availability

### Example
```dart
import 'package:bytebeams_api/api.dart';

final api = BytebeamsApi().getDefaultApi();

try {
    final response = api.getHealth();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getHealth: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**HealthResponse**](HealthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **streamTelemetry**
> String streamTelemetry(after, lastEventID)

Stream live telemetry deliveries

Streams TelemetryDelivery events. Reconnect with Last-Event-ID.

### Example
```dart
import 'package:bytebeams_api/api.dart';

final api = BytebeamsApi().getDefaultApi();
final String after = after_example; // String | 
final String lastEventID = lastEventID_example; // String | 

try {
    final response = api.streamTelemetry(after, lastEventID);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->streamTelemetry: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **after** | **String**|  | [optional] 
 **lastEventID** | **String**|  | [optional] 

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/event-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

