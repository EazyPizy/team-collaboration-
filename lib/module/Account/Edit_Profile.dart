import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'ctlr_customer_profile.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return GetBuilder<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Edit Profile',
            ),
          ),
          body: EasyContainer(
            padding: 10,
            color: EazyColors.white,
            child: Column(
              children: [
                Space.vertical(10.h),
                Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 100.h,
                          width: 100.w,
                          child: controller.imageFile == null
                              ? EazyNetworkImage(
                                  url: controller
                                          .eazyman.personalDetail?.images ??
                                      '',
                                  // fit: BoxFit.fill,
                                )
                              : Image.file(controller.imageFile!),
                        ),
                        IconButton(
                          onPressed: () => _showPicker(controller),
                          icon: const Icon(Icons.camera),
                        ),
                      ],
                    ),
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: IconButton(
                    //     onPressed: () => _showPicker(controller),
                    //     icon: const Icon(Icons.edit),
                    //   ),
                    // ),
                  ],
                ),
                Space.vertical(30.h),
                Form(
                  key: formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: EazyTextField.stringTextField(
                          'First Name Can\'t be Empty!',
                          // TextInputAction.next,
                          // textInputType: TextInputType.text,
                          // length: 15,
                          hintText: 'Enter First Name',
                          controller: controller.firstNameController,
                        ),
                      ),
                      Space.horizontal(8),
                      Expanded(
                        child: EazyTextField.stringTextField(
                          'Last Name Can\'t be Empty!',
                          // TextInputAction.next,
                          // TextInputType.text,
                          // length: 15,
                          hintText: 'Enter Last Name',
                          controller: controller.lastNameController,
                        ),
                      ),
                    ],
                  ),
                ),
                Space.vertical(10.h),
                const Spacer(),
                if (controller.loading)
                  const Center(
                    child: EazyLoadingWidget(),
                  )
                else if (controller.detailsChange)
                  EazyButtons.fullWidthElevatedButton('Update', () {
                    if (formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      controller.updateEazymanDetails();
                    }
                  }),
                Space.vertical(8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPicker(EditProfileController controller) {
    showModalBottomSheet(
      context: Get.context!,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  controller.imgFromGallery();
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  controller.imgFromCamera();
                  Get.back();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
