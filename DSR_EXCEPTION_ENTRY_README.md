# DSR Exception Entry - Dynamic API Integration

## Overview
The DSR Exception Entry page has been updated to use dynamic API endpoints instead of hardcoded data. This provides real-time data fetching and submission capabilities.

## Changes Made

### 1. New Models Created
**File:** `lib/data/models/dsr_exception_models.dart`

- `ExceptionMetadata` - Contains exception types, status flags, and approver information
- `ExceptionType` - Individual exception type with code and description
- `StatusFlag` - Status flag with code and description
- `ExceptionRequest` - Request data structure
- `ExceptionHistory` - History record structure
- `ExceptionSubmission` - Submission data structure

### 2. New Service Created
**File:** `lib/data/services/dsr_exception_service.dart`

API endpoints integrated:
- `GET /api/DsrTry/getExceptionMetadata` - Fetches metadata (exception types, status flags, approver)
- `GET /api/DsrTry/getExceptionRequests` - Fetches requests (new blank row or pending approvals)
- `GET /api/DsrTry/getExceptionHistory` - Fetches history (created/pending entries)
- `POST /api/DsrTry/submitExceptions` - Submits exception entries

### 3. Updated Page
**File:** `lib/features/dsr_entry/presentation/pages/dsr_exception_entry.dart`

#### Key Features Added:
- **Dynamic Data Loading**: All data is now fetched from APIs
- **Loading States**: Shows loading indicators while fetching data
- **Error Handling**: Displays error messages with retry buttons
- **Real-time Submission**: Submits data to backend API
- **Form Validation**: Validates required fields before submission
- **Auto-refresh**: Reloads data after successful submission
- **Empty States**: Shows appropriate messages when no data is available

#### UI Improvements:
- Dynamic approver name in warning box
- Dynamic exception types in dropdown
- Dynamic employee information
- Real-time history display
- Better error messaging with retry options
- Loading indicators for better UX

## API Integration Details

### Base URL
```
http://192.168.36.25/api/DsrTry
```

### Endpoints Used

1. **getExceptionMetadata**
   - Purpose: Get exception types, status flags, and approver
   - Method: GET
   - Query params: `procType` (default: 'N')

2. **getExceptionRequests**
   - Purpose: Get user data for new entries or pending approvals
   - Method: GET
   - Query params: `procType` (default: 'N'), `emplCode` (optional)

3. **getExceptionHistory**
   - Purpose: Get exception history for the user
   - Method: GET
   - Query params: `procType` (default: 'N')

4. **submitExceptions**
   - Purpose: Submit new exception entries
   - Method: POST
   - Body: Array of ExceptionSubmission objects

## Usage

1. **Loading Data**: The page automatically loads all required data on initialization
2. **Creating Exception**: Fill in exception type, date, and remarks, then submit
3. **Viewing History**: Scroll down to see exception history
4. **Error Recovery**: Use retry buttons if data loading fails
5. **Refresh**: Use the refresh button in the app bar to reload all data

## Error Handling

The page includes comprehensive error handling:
- Network errors with retry options
- Validation errors for form submission
- Loading states to prevent multiple submissions
- User-friendly error messages

## Dependencies

The implementation uses the existing `http` package that's already included in the project's `pubspec.yaml`.

## Testing

To test the implementation:
1. Ensure the backend API is running at `http://192.168.36.25/api/DsrTry`
2. Navigate to the DSR Exception Entry page
3. Verify that data loads correctly
4. Test form submission with valid data
5. Test error scenarios (network issues, validation errors) 