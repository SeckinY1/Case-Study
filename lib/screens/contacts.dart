import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:task/elements/constants_widgets.dart';
import 'package:task/services_functions.dart';
import 'package:task/task_icons.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

enum ButtonStatus { done, edit }

class _ContactsScreenState extends State<ContactsScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  bool isDone = false;

  ButtonStatus buttonStatus = ButtonStatus.done;

  ValueNotifier<bool> isDoneEnabled = ValueNotifier(false);

  File? _image;

  @override
  void initState() {
    Provider.of<ApiService>(context, listen: false).getUsers();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants().pageColor,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 40),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Contacts",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        buttonStatus = ButtonStatus.done;
                      });
                      bottomPopUpBar(null, firstNameController.text, lastNameController.text, phoneNumberController.text);
                    },
                    child: Icon(
                      Task.add,
                      size: 24,
                      color: Constants().blue,
                    ))
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
                height: 40,
                child: TextFormField(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Constants().grey),
                  cursorColor: Constants().blue,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Task.search),
                    fillColor: Constants().white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    isDense: true,
                    hintText: "Search by name",
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Constants().grey),
                  ),
                )),
            Provider.of<ApiService>(context, listen: true).users.isEmpty ? const Spacer() : const SizedBox(),
            Provider.of<ApiService>(context, listen: true).users.isEmpty
                ? Column(
                    children: [
                      Icon(
                        Task.contact,
                        size: 60,
                        color: Constants().grey,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "No Contacts",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 7),
                      Text("Contacts you’ve added will appear here.", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 7),
                      InkWell(
                          onTap: () {
                            setState(() {
                              buttonStatus = ButtonStatus.done;
                            });
                            bottomPopUpBar(null, firstNameController.text, lastNameController.text, phoneNumberController.text);
                          },
                          child: Text(
                            "Create New Contact",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Constants().blue),
                          )),
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: Provider.of<ApiService>(context, listen: false).users.length,
                    itemBuilder: (context, index) {
                      var apiService = Provider.of<ApiService>(context, listen: false).users[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ListTile(
                          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          tileColor: Constants().white,
                          leading: ClipOval(
                              child: Image.network(
                            apiService.profileImageUrl,
                            fit: BoxFit.cover,
                            width: 34,
                            height: 34,
                          )),
                          title: Text(
                            "${Provider.of<ApiService>(context, listen: false).users[index].firstName} ${Provider.of<ApiService>(context, listen: false).users[index].lastName}",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            Provider.of<ApiService>(context, listen: false).users[index].phoneNumber,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Constants().grey),
                          ),
                          onTap: () async {
                            setState(() {
                              buttonStatus = ButtonStatus.edit;
                            });
                            await bottomPopUpBar(apiService.profileImageUrl, apiService.firstName, apiService.lastName, apiService.phoneNumber);
                          },
                        ),
                      );
                    },
                  ),
            Provider.of<ApiService>(context, listen: false).users.isEmpty ? const Spacer() : const SizedBox(),
          ],
        ),
      )),
    );
  }

  void validateInputs() {
    bool isValid = firstNameController.text.isNotEmpty && lastNameController.text.isNotEmpty && phoneNumberController.text.isNotEmpty;

    isDoneEnabled.value = isValid;
  }

  void clearInputs() {
    _image = null;
    firstNameController.clear();
    lastNameController.clear();
    phoneNumberController.clear();
    setState(() {});
  }

  bottomPopUpBar(String? imagePathUrl, String firstName, String lastName, String phoneNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Constants().white,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        if (buttonStatus == ButtonStatus.done) {
          firstNameController.addListener(validateInputs);
          lastNameController.addListener(validateInputs);
          phoneNumberController.addListener(validateInputs);
        }

        return StatefulBuilder(
          builder: (BuildContext context, setModalState) {
            return WillPopScope(
              onWillPop: () async {
                if (buttonStatus == ButtonStatus.done) {
                  clearInputs();
                }
                return true;
              },
              child: Container(
                  height: screenHeight * 0.95,
                  padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                  child: buttonStatus == ButtonStatus.edit ? editScreenWidgets(setModalState, imagePathUrl!, firstName, lastName, phoneNumber) : doneScreenWidgets(setModalState)),
              // child: Container()),
            );
          },
        );
      },
    ).whenComplete(
      () {
        if (buttonStatus == ButtonStatus.done) {
          clearInputs();
        }
      },
    );
  }

  Widget doneScreenWidgets(setModalState) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                firstNameController.clear();
                lastNameController.clear();
                phoneNumberController.clear();
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Constants().blue),
              ),
            ),
            Text(
              "New Contact",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isDoneEnabled,
              builder: (context, value, child) {
                return TextButton(
                  onPressed: value && _image != null
                      ? () async {
                          final userData = {
                            "firstName": firstNameController.text,
                            "lastName": lastNameController.text,
                            "phoneNumber": phoneNumberController.text,
                            "profileImageUrl": _image?.path ?? "",
                          };

                          try {
                            final apiService = ApiService();

                            await apiService.uploadImageAndCreateUser(
                              imageFile: File(_image!.path),
                              firstName: firstNameController.text,
                              lastName: lastNameController.text,
                              phoneNumber: phoneNumberController.text,
                            );
                            print(userData);
                            setModalState(() {
                              buttonStatus = ButtonStatus.edit;

                              // print(contactaMap);
                            });
                          } catch (e) {
                            print('Hata oluştu: $e');
                          }
                        }
                      : null,
                  child: Text(
                    "Done",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: value && _image != null ? Constants().blue : Constants().grey),
                  ),
                );
              },
            )
          ],
        ),
        const SizedBox(height: 40.5),
        _image == null
            ? Icon(
                Task.contact,
                size: 195,
                color: Constants().grey,
              )
            : ClipOval(
                child: Image.file(
                _image!,
                fit: BoxFit.cover,
                width: 195,
                height: 195,
              )),
        const SizedBox(height: 14.5),
        InkWell(
          onTap: () async {
            await addPhotoBottomBar(setModalState);
          },
          child: Text(
            _image == null ? "Add Photo" : "Change Photo",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        textFieldArea("First name", firstNameController),
        textFieldArea("Last name", lastNameController),
        textFieldArea("Phone number", phoneNumberController),
      ],
    );
  }

  Widget editScreenWidgets(setModalState, String profileImageUrl, String firstName, String lastName, String phoneNumber) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Constants().blue),
              ),
            ),
            Text(
              "New Contact",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isDoneEnabled,
              builder: (context, value, child) {
                return TextButton(
                  onPressed: () {
                    setModalState(() {
                      buttonStatus = ButtonStatus.done;
                    });
                  },
                  child: Text(
                    "Edit",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: value && _image != null ? Constants().blue : Constants().grey),
                  ),
                );
              },
            )
          ],
        ),
        const SizedBox(height: 40.5),
        ClipOval(
            child: Image.network(
          profileImageUrl,
          fit: BoxFit.cover,
          width: 195,
          height: 195,
        )),
        const SizedBox(height: 14.5),
        InkWell(
          onTap: () async {
            await addPhotoBottomBar(setModalState);
          },
          child: Text(
            "Change Photo",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        textArea(firstName),
        textArea(lastName),
        textArea(phoneNumber),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {},
            child: Text(
              "Delete contact",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Constants().redDeleteAccount),
            ),
          ),
        )
      ],
    );
  }

  addPhotoBottomBar(setState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Constants().white,
      builder: (context) {
        return IntrinsicHeight(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: buttonStatus == ButtonStatus.edit ? 15 : 30, vertical: 30),
            child: Column(
              children: [
                elevatedButtonForAddPhotoArea(
                    Task.camera,
                    "Camera",
                    () => setState(() {
                          _pickImage(ImageSource.camera, setState);
                        }),
                    Constants().black),
                const SizedBox(
                  height: 15,
                ),
                elevatedButtonForAddPhotoArea(
                    Task.picture,
                    "Gallery",
                    () => setState(() {
                          _pickImage(ImageSource.gallery, setState);
                        }),
                    Constants().black),
                const SizedBox(
                  height: 15,
                ),
                elevatedButtonForAddPhotoArea(null, "Cancel", () => Navigator.pop(context), Constants().blue)
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, setState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Seçilen fotoğrafı değişkende tutuyoruz
      });
      Navigator.pop(context);
      print('Image Path: ${_image?.path}');
    }
  }

  elevatedButtonForAddPhotoArea(IconData? icon, String text, VoidCallback onPressed, Color textColor) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Constants().pageColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon != null
                  ? Icon(
                      icon,
                      color: Constants().black,
                    )
                  : const SizedBox(),
              const SizedBox(
                width: 15,
              ),
              Text(
                text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor),
              )
            ],
          ),
        ));
  }

  textFieldArea(String hintText, TextEditingController controller) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        height: 43,
        child: TextFormField(
          controller: controller,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Constants().black),
          cursorColor: Constants().blue,
          decoration: InputDecoration(
            fillColor: Constants().pageColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            isDense: true,
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Constants().grey),
          ),
        ));
  }

  Widget textArea(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 15), child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        Divider(
          color: Constants().grey,
        )
      ],
    );
  }
}
