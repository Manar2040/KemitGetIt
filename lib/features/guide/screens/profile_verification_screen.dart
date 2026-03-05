import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kemit_get_it/features/guide/screens/home_screen.dart';
import 'package:kemit_get_it/features/guide/widgets/widget_upload.dart';


class ProfileVerificationScreen extends StatefulWidget {
  const ProfileVerificationScreen({super.key});

  @override
  State<ProfileVerificationScreen> createState() =>
      _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState extends State<ProfileVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController regionsController = TextEditingController();

  final List<String> specializations = ["Historical", "Adventure", "Cultural"];

  List<String> selectedSpecializations = [];

  File? idImage;
  File? personalImage;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(bool isId) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isId) {
          idImage = File(image.path);
        } else {
          personalImage = File(image.path);
        }
      });
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    phoneController.dispose();
    specializationController.dispose();
    bioController.dispose();
    regionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tell us more about you",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please provide the following information to help us find the best experiences for you",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              const Text(
                "Phone",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Phone",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone is required";
                  }
                  if (value.length < 10) {
                    return "Invalid phone number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// Specialization
              const Text(
                "Specialization",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: specializationController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Specialization",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Specialization is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: specializations.map((item) {
                  return ChoiceChip(
                    label: Text(item, style: TextStyle(color: Colors.black)),
                    selected: selectedSpecializations.contains(item),
                    selectedColor: Color.fromARGB(255, 168, 166, 166),
                    backgroundColor: Color(0xFFCCCCCC),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          selectedSpecializations.add(item);
                        } else {
                          selectedSpecializations.remove(item);
                        }

                        specializationController.text = selectedSpecializations
                            .join(", ");
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              const Text(
                "Verification Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: uploadBox(
                      title: "Upload ID Card",
                      image: idImage,
                      onTap: () => pickImage(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: uploadBox(
                      title: "Personal Photo",
                      image: personalImage,
                      onTap: () => pickImage(false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                "Professional Bio",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      "Tell us about your technical background and expertise...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Bio is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              const Text(
                "Favorite Working Regions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: regionsController,
                decoration: InputDecoration(
                  hintText: "Favorite Working Regions",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Region is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    if (selectedSpecializations.isEmpty) {
                      showSnack("Please select at least one specialization");
                      return;
                    }

                    if (idImage == null || personalImage == null) {
                      showSnack("Please upload all documents");
                      return;
                    }
                    Navigator.push(
                      context,
                       MaterialPageRoute(builder: (context)=>HomeScreen())
                       );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAAAAAA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Submit For Verification",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}
