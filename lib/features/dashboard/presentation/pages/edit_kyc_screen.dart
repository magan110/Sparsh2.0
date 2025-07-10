import 'package:flutter/material.dart';

class EditKycScreen extends StatefulWidget {
  const EditKycScreen({super.key});

  @override
  State<EditKycScreen> createState() => _EditKycScreenState();
}

class _EditKycScreenState extends State<EditKycScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController retailerCodeController = TextEditingController();
  final TextEditingController stockistCodeController = TextEditingController();
  final TextEditingController firmNameController = TextEditingController();
  final TextEditingController tallyRetailerCodeController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController concernEmployeeController = TextEditingController();
  final TextEditingController panNoController = TextEditingController();
  final TextEditingController identityNoController = TextEditingController();
  final TextEditingController proprietorNameController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController address3Controller = TextEditingController();
  final TextEditingController officeTel1Controller = TextEditingController();
  final TextEditingController officeTel2Controller = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController bankBranchNoController = TextEditingController();
  final TextEditingController bankBranchNameController = TextEditingController();
  final TextEditingController bankBranchDescController = TextEditingController();
  final TextEditingController accountHolderNameController = TextEditingController();
  final TextEditingController businessStartYearController = TextEditingController();
  final TextEditingController bwStartYearController = TextEditingController();
  final TextEditingController remarksKycController = TextEditingController();

  // Dropdown values
  String? processType;
  String? area;
  String? schemeRequired;
  String? identityType;
  String? state;
  String? district;
  String? pinCode;
  String? typeOfBusiness;
  String? paintNonPaintType;
  String? kycVerified;
  String? webAccess;
  String? sparshLoginRequired;
  String? activeStatus;
  String? retailerClass;
  String? accountHolderFlag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit KYC'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Basic Details'),
                _verticalSpace(),
                _dropdownField('Process Type', processType, ['Add', 'Update', 'Delete'], (v) => setState(() => processType = v)),
                _verticalSpace(),
                _dropdownField('Area', area, ['Area1', 'Area2', 'Area3'], (v) => setState(() => area = v)),
                _verticalSpace(),
                _textField('Retailer Code', retailerCodeController),
                _verticalSpace(),
                _textField('Stockist Code', stockistCodeController),
                _verticalSpace(),
                _textField('Firm Name', firmNameController),
                _verticalSpace(),
                _textField('Tally Retailer Code', tallyRetailerCodeController),
                _verticalSpace(),
                _textField('GST Number', gstNumberController),
                _verticalSpace(),
                _textField('Concern Employee', concernEmployeeController),
                _verticalSpace(),
                _imageUploadField('Retailer Profile Image'),
                _verticalSpace(),
                _textField('PAN No', panNoController),
                _verticalSpace(),
                _imageUploadField('PAN Image Upload/View'),
                _verticalSpace(),
                _dropdownField('Scheme Required', schemeRequired, ['Yes', 'No'], (v) => setState(() => schemeRequired = v)),
                _verticalSpace(),
                _dropdownField('Identity Type', identityType, ['Aadhar Card', 'Ration Card', 'Electricity/Telephone Bill'], (v) => setState(() => identityType = v)),
                _verticalSpace(),
                _textField('Identity No.', identityNoController),
                _verticalSpace(),
                _imageUploadField('Identity Image Upload/View'),
                _divider(),
                _sectionTitle('Contact Details'),
                _verticalSpace(),
                _textField('Proprietor/Partner Name', proprietorNameController),
                _verticalSpace(),
                _textField('Address 1', address1Controller),
                _verticalSpace(),
                _textField('Address 2', address2Controller),
                _verticalSpace(),
                _textField('Address 3', address3Controller),
                _verticalSpace(),
                _textField('Office Telephone 1', officeTel1Controller),
                _verticalSpace(),
                _textField('Office Telephone 2', officeTel2Controller),
                _verticalSpace(),
                _textField('Mobile', mobileController),
                _verticalSpace(),
                _textField('Email', emailController),
                _verticalSpace(),
                _dropdownField('State', state, ['State1', 'State2'], (v) => setState(() => state = v)),
                _verticalSpace(),
                _dropdownField('District', district, ['District1', 'District2'], (v) => setState(() => district = v)),
                _verticalSpace(),
                _dropdownField('Pin Code', pinCode, ['123456', '654321'], (v) => setState(() => pinCode = v)),
                _verticalSpace(),
                _textField('City', cityController),
                _divider(),
                _sectionTitle('Bank Details'),
                _verticalSpace(),
                _textField('IFSC Code', ifscController),
                _verticalSpace(),
                _textField('Account Number', accountNoController),
                _verticalSpace(),
                _imageUploadField('Bank Document Upload'),
                _verticalSpace(),
                _textField('Bank Branch No', bankBranchNoController),
                _verticalSpace(),
                _textField('Bank Branch Name', bankBranchNameController),
                _verticalSpace(),
                _textField('Bank Branch Description', bankBranchDescController),
                _divider(),
                _sectionTitle('Business Details'),
                _verticalSpace(),
                _dropdownField('Account Holder Flag', accountHolderFlag, ['Firm Name', 'Proprietor/Partner Name'], (v) => setState(() => accountHolderFlag = v)),
                _verticalSpace(),
                _textField('Account Holder Name', accountHolderNameController),
                _verticalSpace(),
                _textField('Business Started Year', businessStartYearController),
                _verticalSpace(),
                _textField('Started with BirlaWhite Year', bwStartYearController),
                _verticalSpace(),
                _dropdownField('Type of Business', typeOfBusiness, ['Type1', 'Type2'], (v) => setState(() => typeOfBusiness = v)),
                _verticalSpace(),
                _dropdownField('Paint/Non-Paint Type', paintNonPaintType, ['Paint', 'Non-Paint'], (v) => setState(() => paintNonPaintType = v)),
                _verticalSpace(),
                _dropdownField('KYC Verified', kycVerified, ['Yes', 'No'], (v) => setState(() => kycVerified = v)),
                _verticalSpace(),
                _dropdownField('Web Access', webAccess, ['Yes', 'No'], (v) => setState(() => webAccess = v)),
                _verticalSpace(),
                _dropdownField('SPARSH Login Required', sparshLoginRequired, ['Yes', 'No'], (v) => setState(() => sparshLoginRequired = v)),
                _verticalSpace(),
                _dropdownField('Active Status', activeStatus, ['Active', 'Inactive'], (v) => setState(() => activeStatus = v)),
                _verticalSpace(),
                _dropdownField('Retailer Class', retailerClass, ['Class1', 'Class2'], (v) => setState(() => retailerClass = v)),
                _divider(),
                _sectionTitle('KYC Remarks'),
                _verticalSpace(),
                TextFormField(
                  controller: remarksKycController,
                  decoration: const InputDecoration(
                    labelText: 'Remarks For KYC Resend',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                _verticalSpace(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Submit logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('KYC Updated (mock)')),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
                _verticalSpace(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      );

  Widget _divider() => const Divider(height: 36, thickness: 1.3);

  Widget _verticalSpace({double height = 16}) => SizedBox(height: height);

  Widget _textField(String label, TextEditingController controller) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
      );

  Widget _dropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      );

  Widget _imageUploadField(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      // TODO: Implement image picker/upload
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      // TODO: Implement image view
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
