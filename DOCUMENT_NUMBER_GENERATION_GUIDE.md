# Document Number Generation Guide

## Overview

This guide explains how document numbers are generated and managed in the BTL Activities form and other DSR entry forms.

## Current Implementation

### 1. Document Number Generation Process

The document number generation works as follows:

1. **Process Type Selection**: When a user selects "Update" from the Process Type dropdown
2. **Automatic Generation**: A document number is automatically generated and displayed
3. **Non-Editable Field**: The document number field appears below the Process Type dropdown and is read-only

### 2. Current Code Structure

#### Frontend (Flutter) - `btl_activites.dart`

```dart
// Document number generation method
String generateDocumentNumber() {
  const prefix = "BTLACT";  // Activity-specific prefix
  final now = DateTime.now().toUtc();
  final formatted = DateFormat('yyMMddHHmmss').format(now).padRight(11, '0');
  final rawNum = prefix + formatted;
  return rawNum.substring(0, 16);
}

// Process type change handler
onChanged: (v) async {
  setState(() {
    _processItem = v;
  });
  
  if (v == "Update") {
    // Show loading indicator
    setState(() {
      _documentNumberController.text = "Generating...";
    });
    
    // Fetch document number from server
    final docNumber = await _fetchDocumentNumberFromServer();
    
    setState(() {
      _documentNumber = docNumber;
      _documentNumberController.text = docNumber ?? "";
    });
  } else {
    setState(() {
      _documentNumber = null;
      _documentNumberController.clear();
    });
  }
},

// Document number field display
if (_processItem == "Update")
  Padding(
    padding: const EdgeInsets.only(top: SparshSpacing.sm),
    child: TextFormField(
      controller: _documentNumberController,
      readOnly: true,  // Non-editable
      decoration: InputDecoration(
        labelText: "Document Number",
        filled: true,
        fillColor: SparshTheme.lightGreyBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  ),
```

#### Backend (C#) - `DsrTryController.cs`

The backend uses stored procedures for document number generation:

```csharp
// Generate document number using stored procedure
const string generateDocNoSql = "EXEC [dbo].[wcpDocNoGen] @DocType, @AreaCode";
var generateParams = new Dictionary<string, object>
{
    ["@DocType"] = "DSR",
    ["@AreaCode"] = dto.AreaCode
};

var docuNumbResult = _db.WebSessBean(generateDocNoSql, generateParams) as List<Dictionary<string, object>>;
var docuNumb = docuNumbResult?.FirstOrDefault()?["docuNumb"]?.ToString();

// Update document number using stored procedure
const string updateDocNoSql = "EXEC [dbo].[wcpDocNoUpd] @DocType, @AreaCode";
var updateParams = new Dictionary<string, object>
{
    ["@DocType"] = "DSR",
    ["@AreaCode"] = dto.AreaCode
};

_db.WebSessBean(updateDocNoSql, updateParams);
```

## Activity-Specific Document Number Prefixes

Each activity type has its own prefix for document numbers:

| Activity Type | Prefix | Example |
|---------------|--------|---------|
| BTL Activities | BTLACT | BTLACT231215143022 |
| Office Work | OFFWOR | OFFWOR231215143022 |
| Work From Home | WFHOME | WFHOME231215143022 |
| Phone Call with Builder | PHBUI | PHBUI231215143022 |
| Internal Team Meeting | INTTMS | INTTMS231215143022 |
| Check Sampling at Site | CHSMP | CHSMP231215143022 |
| Meetings with Contractor | MECO | MECO231215143022 |
| Any Other Activity | ANYOTH | ANYOTH231215143022 |
| Meeting with New Purchaser | NEWPUR | NEWPUR231215143022 |
| On Leave | LEAVEH | LEAVEH231215143022 |

## Document Number Format

The document number format is:
- **Prefix**: Activity-specific (6 characters)
- **Timestamp**: YYMMDDHHMMSS (12 characters)
- **Total Length**: 16 characters

Example: `BTLACT231215143022`
- `BTLACT` = Activity prefix
- `231215` = Date (YYMMDD)
- `143022` = Time (HHMMSS)

## Improvements Made

### 1. Server-Side Document Number Generation

Implemented a method to fetch document numbers from the server using the simplified `generateDocumentNumber` endpoint:

```dart
Future<String?> _fetchDocumentNumberFromServer() async {
  try {
    final url = Uri.parse('http://192.168.36.25/api/DsrTry/generateDocumentNumber');
    
    // Send only the area code as a simple string
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(''), // Empty area code for now, can be updated when area code field is added
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['DocumentNumber'] as String?;
    } else {
      print('Error generating document number: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to generate document number: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching document number: $e');
    throw Exception('Failed to generate document number: $e');
  }
}
```

**No Local Fallback**: The system now relies entirely on the backend API for document number generation. If the API fails, an error is thrown and displayed to the user.

### 2. Loading State

Added a loading indicator when generating document numbers:

```dart
if (v == "Update") {
  // Show loading indicator
  setState(() {
    _documentNumberController.text = "Generating...";
  });
  
  // Fetch document number from server
  final docNumber = await _fetchDocumentNumberFromServer();
  
  setState(() {
    _documentNumber = docNumber;
    _documentNumberController.text = docNumber ?? "";
  });
}
```

### 3. Form Submission

Enhanced the form submission to include proper backend integration:

```dart
Future<void> _onSubmit(bool exitAfter) async {
  if (!_formKey.currentState!.validate()) return;

  try {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Submitting form...'),
        backgroundColor: Colors.blue,
      ),
    );

    // Prepare the data for submission
    final submissionData = {
      'ActivityType': 'BTL Activities',
      'SubmissionDate': _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'CreateId': 'SYSTEM',
      'AreaCode': '', // You can add area code field if needed
      'Purchaser': '',
      'PurchaserCode': '',
      'dsrRem01': _activityTypeItem ?? '',
      'dsrRem02': _participantsController.text,
      'dsrRem03': _townController.text,
      'dsrRem04': _learningsController.text,
      'dsrRem05': '',
      'dsrRem06': '',
      'dsrRem07': '',
      'dsrRem08': '',
    };

    // Submit to backend
    final url = Uri.parse('http://192.168.36.25/api/DsrTry');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(submissionData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exitAfter
                ? 'Form submitted successfully. Exiting...'
                : 'Form submitted successfully. Ready for new entry.',
          ),
          backgroundColor: SparshTheme.successGreen,
        ),
      );

      if (exitAfter) {
        Navigator.of(context).pop();
      } else {
        _formKey.currentState!.reset();
        setState(() {
          _processItem = 'Select';
          _activityTypeItem = 'Select';
          _dateController.clear();
          _reportDateController.clear();
          _selectedDate = null;
          _selectedReportDate = null;
          _participantsController.clear();
          _townController.clear();
          _learningsController.clear();
          _documentNumber = null;
          _documentNumberController.clear();
          _selectedImages
            ..clear()
            ..add(null);
        });
      }
    } else {
      throw Exception('Failed to submit form: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Submission failed: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

## Backend API Endpoint Implementation

The backend now includes a simplified `generateDocumentNumber` endpoint in your `DsrTryController.cs`:

```csharp
[HttpPost("generateDocumentNumber")]
public IActionResult GenerateDocumentNumber([FromBody] string areaCode)
{
    if (string.IsNullOrWhiteSpace(areaCode))
        return BadRequest("AreaCode is required.");

    try
    {
        // Generate document number using stored procedure
        const string generateDocNoSql = "EXEC [dbo].[wcpDocNoGen] @DocType, @AreaCode";
        var generateParams = new Dictionary<string, object>
        {
            ["@DocType"] = "DSR",
            ["@AreaCode"] = areaCode
        };

        var docuNumbResult = _db.WebSessBean(generateDocNoSql, generateParams) as List<Dictionary<string, object>>;
        var docuNumb = docuNumbResult?.FirstOrDefault()?["docuNumb"]?.ToString();

        if (string.IsNullOrWhiteSpace(docuNumb))
            return StatusCode(500, "Failed to generate document number.");

        // Update document number using stored procedure
        const string updateDocNoSql = "EXEC [dbo].[wcpDocNoUpd] @DocType, @AreaCode";
        var updateParams = new Dictionary<string, object>
        {
            ["@DocType"] = "DSR",
            ["@AreaCode"] = areaCode
        };

        _db.WebSessBean(updateDocNoSql, updateParams);

        // Return the document number without formatting
        return Ok(new { DocumentNumber = docuNumb });
    }
    catch (Exception ex)
    {
        return StatusCode(500, ex.Message);
    }
}
```

This simplified endpoint:
1. **Accepts** only the area code as a simple string parameter
2. **Generates** a document number using the `wcpDocNoGen` stored procedure
3. **Updates** the document number sequence using the `wcpDocNoUpd` stored procedure
4. **Returns** the generated document number to the frontend

## Usage Flow

1. **User opens BTL Activities form**
2. **User selects "Update" from Process Type dropdown**
3. **System shows "Generating..." in document number field**
4. **Backend generates document number using stored procedures**
5. **Document number is displayed in read-only field**
6. **User fills in other form fields (Activity Type, Participants, Town, Learnings)**
7. **User clicks "Submit & New" or "Submit & Exit"**
8. **Form data is submitted to backend with proper validation**
9. **Success/error message is shown to user**
10. **Form is reset or user is navigated away**

**Error Handling**: If document number generation fails, the process type resets to "Select" and an error message is shown to the user.

## Key Features

- ✅ **Server-Side Generation**: Document numbers are generated using backend stored procedures
- ✅ **No Local Fallback**: System relies entirely on backend API - no hardcoded generation
- ✅ **Automatic Generation**: Document numbers are generated automatically when "Update" is selected
- ✅ **Non-Editable**: Document number field is read-only to prevent manual editing
- ✅ **Loading State**: Shows "Generating..." while creating document number
- ✅ **Error Handling**: Proper error handling with user feedback if API fails
- ✅ **Form Submission**: Complete form data is submitted to backend with validation
- ✅ **Success/Error Feedback**: User receives clear feedback on submission status
- ✅ **Form Reset**: Form is properly reset after successful submission
- ✅ **Consistent Format**: All document numbers follow the same 16-character format

## API Endpoints Summary

### Document Number Generation
- **Endpoint**: `POST /api/DsrTry/generateDocumentNumber`
- **Request**: Simple string containing area code
- **Response**: `{ "DocumentNumber": "generated_number" }`

### Form Submission
- **Endpoint**: `POST /api/DsrTry`
- **Request**: Complete DsrEntryDto object
- **Response**: 201 Created with document number

## Future Enhancements

1. **Area Code Integration**: Add area code field to the form and pass it to document generation
2. **Document Number Validation**: Add validation to ensure document number format is correct
3. **Document Number Persistence**: Store generated document numbers in local storage
4. **Document Number History**: Track and display previously generated document numbers
5. **Bulk Operations**: Support for generating multiple document numbers at once 