import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:smart_assist/pages/navbar_page/app_setting.dart';
import 'package:smart_assist/pages/navbar_page/call_analytics.dart';
import 'package:smart_assist/pages/navbar_page/call_logs.dart';
import 'package:smart_assist/pages/navbar_page/favorite.dart';
import 'package:smart_assist/pages/navbar_page/leads_all.dart';
import 'package:smart_assist/pages/navbar_page/logout_page.dart';
import 'package:smart_assist/pages/navbar_page/my_teams.dart';
import 'package:smart_assist/widgets/profile_screen.dart';

// Import with alias to avoid conflicts
import 'package:smart_assist/utils/navigation_controller.dart' as nav_utils;

class BottomNavigation extends StatelessWidget {
  BottomNavigation({super.key});

  final nav_utils.NavigationController controller =
      Get.put(nav_utils.NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => controller.screens[controller.selectedIndex.value]),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Update the method to not require a parameter
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Obx(
            () {
              List<Widget> navItems = [
                _buildNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    index: 0,
                    isIcon: true,
                    isImg: false),
              ];

              // Insert Teams navigation only for SM role
              if (controller.userRole.value == "SM") {
                navItems.add(_buildNavItem(
                    icon: Icons.people_alt_outlined,
                    label: 'My Teams',
                    index: 1,
                    isIcon: true,
                    isImg: false));
              }

              // Add Calendar - index needs to be adjusted based on whether Teams is present
              int calendarIndex = controller.userRole.value == "SM" ? 2 : 1;
              navItems.add(_buildNavItem(
                  isImg: true,
                  isIcon: false,
                  img: Image.asset(
                    'assets/calendar.png',
                    fit: BoxFit.contain,
                  ),
                  label: 'Calendar',
                  index: calendarIndex));

              // Add More/Settings - index needs to be adjusted based on whether Teams is present
              int moreIndex = controller.userRole.value == "SM" ? 3 : 2;
              navItems.add(_buildNavItem(
                  icon: Icons.settings,
                  label: 'More',
                  index: moreIndex,
                  isIcon: true,
                  isImg: false,
                  onTap: _showMoreBottomSheet));

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: navItems,
              );
            },
          ),
        ),
      ),
    );
    //   child: SafeArea(
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 0),
    //       child: Obx(
    //         () => Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceAround,
    //           children: [
    //             _buildNavItem(
    //                 icon: Icons.home,
    //                 label: 'Home',
    //                 index: 0,
    //                 isIcon: true,
    //                 isImg: false),
    //             _buildNavItem(
    //                 icon: Icons.people_alt_outlined,
    //                 label: 'My Teams',
    //                 index: 1,
    //                 isIcon: true,
    //                 isImg: false),
    //             _buildNavItem(
    //                 isImg: true,
    //                 isIcon: false,
    //                 img: Image.asset(
    //                   'assets/calendar.png',
    //                   fit: BoxFit.contain,
    //                 ),
    //                 label: 'Calendar',
    //                 index: 2),
    //             _buildNavItem(
    //                 icon: Icons.settings,
    //                 label: 'More',
    //                 index: 3,
    //                 isIcon: true,
    //                 isImg: false,
    //                 onTap: _showMoreBottomSheet),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  // Update this method to not require a controller parameter
  Widget _buildNavItem({
    Image? img,
    IconData? icon,
    required String label,
    required int index,
    bool isImg = false,
    bool isIcon = false,
    VoidCallback? onTap,
  }) {
    final isSelected = controller.selectedIndex.value == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (onTap != null) {
            onTap();
          } else {
            HapticFeedback.lightImpact();
            controller.selectedIndex.value = index;
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.2 : 1.0,
                child: isImg && img != null
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            isSelected
                                ? AppColors.colorsBlue
                                : AppColors.iconGrey,
                            BlendMode.srcIn,
                          ),
                          child: img,
                        ),
                      )
                    : isIcon && icon != null
                        ? Icon(
                            icon,
                            color: isSelected
                                ? AppColors.colorsBlue
                                : AppColors.iconGrey,
                            size: 22,
                          )
                        : const SizedBox.shrink(),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? AppColors.colorsBlue : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Show Bottom Sheet for More options
  void _showMoreBottomSheet() async {
    // String? teamRole = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getString('USER_ROLE'));

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        // height: teamRole == "Owner" ? 320 : 300,
        height: 312,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.people_alt_outlined, size: 28),
              title:
                  Text('Enquiries', style: GoogleFonts.poppins(fontSize: 18)),
              onTap: () => Get.to(() => const AllLeads()),
            ),
            ListTile(
              leading: const Icon(Icons.call_outlined, size: 28),
              title: Text('Call Analytics',
                  style: GoogleFonts.poppins(fontSize: 18)),
              onTap: () => Get.to(() => const CallAnalytics()),
            ),
            // if (teamRole == "Owner")
            //   ListTile(
            //     leading: const Icon(Icons.group, size: 28),
            //     title:
            //         Text('My Team ', style: GoogleFonts.poppins(fontSize: 18)),
            //     onTap: () => Get.to(() => const MyTeams()),
            //   ),
            ListTile(
              leading: const Icon(Icons.star_border_rounded, size: 28),
              title:
                  Text('Favourite', style: GoogleFonts.poppins(fontSize: 18)),
              onTap: () => Get.to(() => const FavoritePage(leadId: '')),
            ),
            // ListTile(
            //   leading: const Icon(Icons.person_outline, size: 28),
            //   title: Text('Profile', style: GoogleFonts.poppins(fontSize: 18)),
            //   onTap: () => Get.to(() => const ProfileScreen()),
            // ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, size: 28),
              title: Text('App Settings',
                  style: GoogleFonts.poppins(fontSize: 18)),
              onTap: () => Get.to(() => const AppSetting()),
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined, size: 28),
              title: Text('Logout', style: GoogleFonts.poppins(fontSize: 18)),
              onTap: () => Get.to(() => const LogoutPage()),
            ),
          ],
        ),
      ),
    );
  }
}



// class BottomNavigation extends StatelessWidget {
//   BottomNavigation({super.key});

//   final NavigationController controller = Get.put(NavigationController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Obx(() => controller.screens[controller.selectedIndex.value]),
//         ],
//       ),
//       bottomNavigationBar:
//           _buildBottomNavigationBar(controller), // ✅ Ensure this is included
//     );
//   }
// }

// // ✅ Bottom Navigation Bar
// Widget _buildBottomNavigationBar(NavigationController controller) {
//   return Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           spreadRadius: 1,
//           blurRadius: 10,
//         )
//       ],
//     ),
//     child: SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 0),
//         child: Obx(
//           () => Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                   icon: Icons.people_alt_rounded,
//                   label: 'Enquiry',
//                   index: 0,
//                   isIcon: true,
//                   isImg: false,
//                   controller: controller),

//               _buildNavItem(
//                   icon: Icons.people_alt_outlined,
//                   label: 'My Teams',
//                   index: 1,
//                   isIcon: true,
//                   isImg: false,
//                   controller: controller),

//               // SizedBox(width: 10), // Space for the FAB
//               _buildNavItem(
//                   isImg: true,
//                   isIcon: false,
//                   img: Image.asset(
//                     'assets/calendar.png',
//                     fit: BoxFit.contain,
//                   ),
//                   label: 'Calendar',
//                   index: 2,
//                   controller: controller),

//               _buildNavItem(
//                   icon: Icons.settings,
//                   label: 'More',
//                   index: 3,
//                   isIcon: true,
//                   isImg: false,
//                   controller: controller),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// // ✅ Bottom Navigation Bar Item
// Widget _buildNavItem({
//   Image? img, // made nullable
//   IconData? icon, // made nullable
//   required String label,
//   required int index,
//   required NavigationController controller,
//   required bool isImg,
//   required bool isIcon,
// }) {
//   final isSelected = controller.selectedIndex.value == index;

//   return Material(
//     color: Colors.transparent,
//     child: InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap: () {
//         HapticFeedback.lightImpact();
//         controller.selectedIndex.value = index;
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AnimatedScale(
//               duration: const Duration(milliseconds: 200),
//               scale: isSelected ? 1.2 : 1.0,
//               child: isImg && img != null
//                   ? SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: ColorFiltered(
//                         colorFilter: ColorFilter.mode(
//                           isSelected
//                               ? AppColors.colorsBlue
//                               : AppColors.iconGrey,
//                           BlendMode.srcIn,
//                         ),
//                         child: img,
//                       ),
//                     )
//                   : isIcon && icon != null
//                       ? Icon(
//                           icon,
//                           color: isSelected
//                               ? AppColors.colorsBlue
//                               : AppColors.iconGrey,
//                           size: 22,
//                         )
//                       : const SizedBox.shrink(),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
//                 color: isSelected ? AppColors.colorsBlue : Colors.black54,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

 

// // ✅ Navigation Controller
// // ✅ Navigation Controller for Calendar Integration
// class NavigationController extends GetxController {
//   final RxInt selectedIndex = 0.obs;
//   final RxBool isFabExpanded = false.obs;

//   // Add selected date and appointments as observable properties
//   final Rx<DateTime> selectedDate = DateTime.now().obs;
//   final RxList appointments = [].obs;
//   final RxList tasks = [].obs;
//   final Rx<CalendarFormat> calendarFormat = CalendarFormat.week.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchInitialData();
//   }

//   // Method to fetch initial data
//   Future<void> fetchInitialData() async {
//     await Future.wait([
//       fetchAppointments(selectedDate.value),
//       fetchTasks(selectedDate.value)
//     ]);
//   }

//   // Method to fetch appointments
//   Future<void> fetchAppointments(DateTime date) async {
//     try {
//       final data = await LeadsSrv.fetchAppointments(date);
//       appointments.value = data;
//     } catch (e) {
//       print('Error fetching appointments: $e');
//       appointments.value = []; // Set to empty list on error
//     }
//   }

//   // Method to fetch tasks
//   Future<void> fetchTasks(DateTime date) async {
//     try {
//       final data = await LeadsSrv.fetchtasks(date);
//       tasks.value = data;
//     } catch (e) {
//       print('Error fetching tasks: $e');
//       tasks.value = []; // Set to empty list on error
//     }
//   }

//   // Method to handle date selection
//   void onDateSelected(DateTime date) {
//     selectedDate.value = date;
//     fetchAppointments(date);
//     fetchTasks(date);
//   }

//   // Use a getter for screens to ensure it always uses current values
//   List<Widget> get screens => [
//         const HomeScreen(greeting: '', leadId: ''),
//         const MyTeams(),
//         const CalendarWithTimeline(
//           // leadId: '',
//           leadName: '',
//         ),
//       ];
// }


// uppper code is working fine 
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/pages/Calendar/calender.dart';
// import 'package:smart_assist/pages/Leads/home_screen.dart';
// import 'package:smart_assist/pages/Leads/opportunity.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/services.dart';
// import 'package:smart_assist/pages/navbar_page/my_teams.dart';
// import 'package:smart_assist/services/leads_srv.dart';
// import 'package:smart_assist/widgets/timeline_view_calender.dart';
// import 'package:table_calendar/table_calendar.dart';

// class BottomNavigation extends StatelessWidget {
//   BottomNavigation({super.key});

//   final NavigationController controller = Get.put(NavigationController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Obx(() => controller.screens[controller.selectedIndex.value]),
//         ],
//       ),
//       bottomNavigationBar:
//           _buildBottomNavigationBar(controller), // ✅ Ensure this is included
//     );
//   }
// }

// // ✅ Bottom Navigation Bar
// Widget _buildBottomNavigationBar(NavigationController controller) {
//   return Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           spreadRadius: 1,
//           blurRadius: 10,
//         )
//       ],
//     ),
//     child: SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 0),
//         child: Obx(
//           () => Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                   icon: Icons.people_alt_rounded,
//                   label: 'Enquiry',
//                   index: 0,
//                   isIcon: true,
//                   isImg: false,
//                   controller: controller),
//               // SizedBox(width: 10), // Space for the FAB
//               _buildNavItem(
//                   isImg: true,
//                   isIcon: false,
//                   img: Image.asset(
//                     'assets/calendar.png',
//                     fit: BoxFit.contain,
//                   ),
//                   label: 'Calendar',
//                   index: 2,
//                   controller: controller),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// // ✅ Bottom Navigation Bar Item
// Widget _buildNavItem({
//   Image? img, // made nullable
//   IconData? icon, // made nullable
//   required String label,
//   required int index,
//   required NavigationController controller,
//   required bool isImg,
//   required bool isIcon,
// }) {
//   final isSelected = controller.selectedIndex.value == index;

//   return Material(
//     color: Colors.transparent,
//     child: InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap: () {
//         HapticFeedback.lightImpact();
//         controller.selectedIndex.value = index;
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AnimatedScale(
//               duration: const Duration(milliseconds: 200),
//               scale: isSelected ? 1.2 : 1.0,
//               child: isImg && img != null
//                   ? SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: ColorFiltered(
//                         colorFilter: ColorFilter.mode(
//                           isSelected
//                               ? AppColors.colorsBlue
//                               : AppColors.iconGrey,
//                           BlendMode.srcIn,
//                         ),
//                         child: img,
//                       ),
//                     )
//                   : isIcon && icon != null
//                       ? Icon(
//                           icon,
//                           color: isSelected
//                               ? AppColors.colorsBlue
//                               : AppColors.iconGrey,
//                           size: 22,
//                         )
//                       : const SizedBox.shrink(),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
//                 color: isSelected ? AppColors.colorsBlue : Colors.black54,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// // ✅ Navigation Controller
// // class NavigationController extends GetxController {
// //   final RxInt selectedIndex = 0.obs;
// //   final RxBool isFabExpanded = false.obs;
// //   final screens = [
// //     const HomeScreen(greeting: '', leadId: ''),
// //     const Opportunity(leadId: ''),
// //     // const MyTeams(),
// //     const Calender(leadId: '', leadName: ''),
// //     // TimelineView(selectedDate: selectedDate, appointments: appointments, onDateSelected: onDateSelected)
// //   ];
// // }

// // ✅ Navigation Controller
// // ✅ Navigation Controller for Calendar Integration
// class NavigationController extends GetxController {
//   final RxInt selectedIndex = 0.obs;
//   final RxBool isFabExpanded = false.obs;

//   // Add selected date and appointments as observable properties
//   final Rx<DateTime> selectedDate = DateTime.now().obs;
//   final RxList appointments = [].obs;
//   final RxList tasks = [].obs;
//   final Rx<CalendarFormat> calendarFormat = CalendarFormat.week.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchInitialData();
//   }

//   // Method to fetch initial data
//   Future<void> fetchInitialData() async {
//     await Future.wait([
//       fetchAppointments(selectedDate.value),
//       fetchTasks(selectedDate.value)
//     ]);
//   }

//   // Method to fetch appointments
//   Future<void> fetchAppointments(DateTime date) async {
//     try {
//       final data = await LeadsSrv.fetchAppointments(date);
//       appointments.value = data;
//     } catch (e) {
//       print('Error fetching appointments: $e');
//       appointments.value = []; // Set to empty list on error
//     }
//   }

//   // Method to fetch tasks
//   Future<void> fetchTasks(DateTime date) async {
//     try {
//       final data = await LeadsSrv.fetchtasks(date);
//       tasks.value = data;
//     } catch (e) {
//       print('Error fetching tasks: $e');
//       tasks.value = []; // Set to empty list on error
//     }
//   }

//   // Method to handle date selection
//   void onDateSelected(DateTime date) {
//     selectedDate.value = date;
//     fetchAppointments(date);
//     fetchTasks(date);
//   }

//   // Use a getter for screens to ensure it always uses current values
//   List<Widget> get screens => [
//         const HomeScreen(greeting: '', leadId: ''),
//         const Opportunity(leadId: ''),
//         // Replace Calendar with CalendarWithTimeline widget
//         // const Calender(leadId: '', leadName: ''),
//         const CalendarWithTimeline(
//           // leadId: '',
//           leadName: '',
//         ),
//       ];
// }

