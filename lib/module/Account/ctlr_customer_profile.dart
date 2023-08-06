import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eazypizy_eazyman/Models/EazymanModel.dart';
import 'package:eazypizy_eazyman/core/logger.dart';
import 'package:eazypizy_eazyman/core/routes.dart';
import 'package:eazypizy_eazyman/core/services/user_service.dart';
import 'package:eazypizy_eazyman/core/typedefs.dart';
import 'package:eazypizy_eazyman/widgets/EasySnackBar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as IMG;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

class EditProfileController extends GetxController {
  final Logger _log = getLogger('EditProfile Controller');
  final _eazymenService = EazyMenService.instance;
  final ImagePicker imagePicker = ImagePicker();

  bool loading = false;
  bool detailsChange = false;

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final EazyMenModel eazyman;

  File? _imageFile;
  File? get imageFile => _imageFile;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    firstNameController = TextEditingController(
        text: _eazymenService.eazyMen!.personalDetail!.firstName);
    lastNameController = TextEditingController(
        text: _eazymenService.eazyMen!.personalDetail!.lastName);

    firstNameController.addListener(() {
      if (!detailsChange) {
        onChange();
      }
    });

    lastNameController.addListener(() {
      if (!detailsChange) {
        onChange();
      }
    });

    eazyman = _eazymenService.eazyMen!;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  void onChange() {
    detailsChange = true;
    update();
  }

  Future imgFromCamera() async {
    final image = await imagePicker.getImage(source: ImageSource.camera);
    if (image != null) {
      setImageFile(File(image.path));
    }
  }

  Future imgFromGallery() async {
    final image = await imagePicker.getImage(source: ImageSource.gallery);
    if (image != null) {
      setImageFile(File(image.path));
    }
  }

  void setImageFile(File image) async {
    loading = true;
    update();
    _imageFile = image;
    await _resizeImage();
    detailsChange = true;
    loading = false;
    update();
  }

  VoidFuture _resizeImage() async {
    IMG.Image? img = IMG.decodeImage(_imageFile!.readAsBytesSync());
    IMG.Image resized = IMG.copyResize(img!, width: 200, height: 200);
    Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));

    final tempDire = await getTemporaryDirectory();
    File file = await File(
            '${tempDire.path}/${_eazymenService.eazyMen!.eazyManUid}.png')
        .create();
    file.writeAsBytesSync(resizedImg);
    _imageFile = file;
  }

  Future<String> uploadImage() async {
    final storageReference = FirebaseStorage.instance;

    final String picture = "Eazyman_Images/${Path.basename(_imageFile!.path)}";

    final uploadTask =
        storageReference.ref().child(picture).putFile(_imageFile!);

    TaskSnapshot snapshot = await uploadTask.whenComplete(() => TaskSnapshot);
    //

    return await snapshot.ref.getDownloadURL();
  }

  VoidFuture updateEazymanDetails() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    final eazyman = _eazymenService.eazyMen!;
    String? imageUrl;

    try {
      loading = true;
      update();
      if (_imageFile != null) {
        imageUrl = await uploadImage();
      }
      final newDetails = eazyman.personalDetail!
          .copyWith(firstName: firstName, lastName: lastName, images: imageUrl);
      await FirebaseFirestore.instance
          .collection('EazyMen')
          .doc(eazyman.eazyManUid)
          .update({
        'Personal_Detail': [newDetails.toJson()],
      });
      _log.i('name updated');
      _log.i('getting customer details....');
      await _eazymenService.fetchEazymenData();

      // Get.back(result: true);
      Get.offAllNamed(Routes.navigationScreen);
      EazySnackBar.buildSuccessSnackbar('Success', 'Eazyman details updated');
    } catch (e) {
      _log.e(e);
      EazySnackBar.buildErronSnackbar(
        'Failed',
        'Something went wrong, Please try again later',
      );
    } finally {
      loading = false;
      update();
    }
  }

  // VoidFuture updateAddress(AddressModel address) async {
  //   try {
  //     loading = true;
  //     update();
  //     await FirebaseFirestore.instance
  //         .collection(FirestoreCollections.customers)
  //         .doc(CustomerService.instance.customer!.id)
  //         .update({
  //       'addresses': [
  //         address.toMap(),
  //       ],
  //     });
  //     _log
  //       ..i('address updated')
  //       ..i('getting customer details....');
  //     await CustomerService.instance.getCustomerData();
  //     Get.back();
  //     EazySnackBar.buildSuccessSnackbar('Success', 'Address updated!');
  //   } catch (e) {
  //     _log.e(e);
  //     EazySnackBar.buildErronSnackbar(
  //       'Failed',
  //       'Something went wrong, Please try again later',
  //     );
  //   } finally {
  //     loading = false;
  //     update();
  //   }
  // }

  // VoidFuture login() async {
  //   await enterMobileNumber();
  //   _eazymenService.stateChange().listen((event) async {
  //     if (event != null) {
  //       await _eazymenService.getCustomerData();
  //       update();
  //     }
  //   });
  // }

  // VoidFuture logout() async {
  //   showLogoutPopup(
  //     onConfirm: _logout,
  //     onCancel: Get.back,
  //   );
  // }

  // VoidFuture _logout() async {
  //   try {
  //     await CustomerService.instance.logout();
  //     // await DBService.instance.clear();
  //     await CartService.instance.clearCart();
  //     await Get.offAll(const NavigationView());
  //     // update();
  //   } catch (e) {
  //     _log.e(e);
  //     EazySnackBar.buildErronSnackbar(
  //       'Error',
  //       'Something went wrong while logging out!',
  //     );
  //   }
  // }
}
