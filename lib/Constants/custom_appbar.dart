import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/MatesController.dart';

import '../Business_Screens/premiumwelcome_screen.dart';
import '../Controller/BusinessPageController.dart';
import '../CustomerSupport/CustomerSupport.dart';
import '../Models/MatesFilterModel.dart';
import '../NotificationScreen/NotificationScreen.dart';
import 'Apis_Constants.dart';

class CustomAppbar extends StatefulWidget {
  const CustomAppbar({super.key});

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();
}

class _CustomAppbarState extends State<CustomAppbar> {
  final Matescontroller matescontroller = Matescontroller();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isSearching = false;
  List<Mates> _searchResults = [];
  OverlayEntry? _searchOverlayEntry;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_handleFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
      _showOverlay();
    } else if (!_searchFocusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchResults.clear();
        });
        _removeOverlay();
        return;
      }
      _performSearch(_searchController.text);
      if (_searchFocusNode.hasFocus) {
        _showOverlay();
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);

    try {
      await matescontroller.MatesFilter(query, "", "", "", [], "", []);

      setState(() {
        _searchResults = matescontroller.matesFilterModel?.mates
                ?.where((mate) =>
                    mate.userName!.toLowerCase().contains(query.toLowerCase()))
                .toList() ??
            [];
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
      if (_searchOverlayEntry != null) {
        _searchOverlayEntry!.markNeedsBuild();
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _searchOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + renderBox.size.height,
        left: position.dx,
        width: renderBox.size.width,
        child: Material(
          color: Colors.transparent,
          child: _buildSearchResults(),
        ),
      ),
    );

    overlayState.insert(_searchOverlayEntry!);
  }

  void _removeOverlay() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).cardColor,
      toolbarHeight: 75,
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xff4F78DA),
                Color(0xff339003),
              ]),
            ),
          )
        ],
      ),
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/Union.svg',
              color: Theme.of(context).primaryColor,
              height: 21,
            ),
          ],
        ),
      ),
      title: SizedBox(
        height: 38,
        child: TextFormField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          cursorHeight: 15,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).hoverColor,
            enabled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.search,
                size: 20,
                color: Theme.of(context).hintColor,
              ),
            ),
            hintText: 'Find friends, activities, or places nearby..',
            hintStyle: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _searchResults.clear();
                      _searchFocusNode.unfocus();
                      _removeOverlay();
                    },
                  )
                : null,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/Vector (1).svg',
            height: 25,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Get.to(() => HelpCenterScreen());
          },
        ),
        IconButton(
          onPressed: () {
            Get.to(() => NotificationScreen());
          },
          icon: Icon(
            Icons.notifications_outlined,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Card(
      margin: EdgeInsets.only(top: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSearching)
              Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_searchResults.isEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No results found',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final mate = _searchResults[index];
                    return _UserSearchTile(mate: mate);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UserSearchTile extends StatelessWidget {
  final Mates mate;

  const _UserSearchTile({required this.mate});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundImage: mate.userProfile?.images?.isNotEmpty ?? false
            ? NetworkImage(mate.userProfile!.images!.first)
            : AssetImage('assets/default_avatar.png') as ImageProvider,
        radius: 20,
      ),
      title: Text(
        mate.userName ?? 'Unknown',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: mate.onlineStatus ?? false ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
            margin: EdgeInsets.only(right: 4),
          ),
          Text(
            mate.onlineStatus ?? false ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        // Get.to(() => UserProfileScreen(userId: mate.userID));
      },
    );
  }
}

class Businessappbar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Businessappbar({super.key, required this.scaffoldKey});

  @override
  State<Businessappbar> createState() => _BusinessappbarState();
}

class _BusinessappbarState extends State<Businessappbar> {
  BusinessController businessController = Get.put(BusinessController());

  @override
  void initState() {
    super.initState();
    businessController.GetBusinessPage();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).cardColor,
      toolbarHeight: 80,
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xff4F78DA),
                Color(0xff339003),
              ]),
            ),
          )
        ],
      ),
      leadingWidth: 69,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: GetBuilder<BusinessController>(
          id: "Activity_update",
          builder: (context) {
            return Row(
              children: [
                InkWell(
                  onTap: () {
                    widget.scaffoldKey.currentState?.openDrawer();
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      '${Apis.ip}${businessController.businessPageModel?.profile?.logo.toString()}',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      title: GetBuilder<BusinessController>(
        id: "Activity_update",
        builder: (_) {
          return Text(
            '${businessController.businessPageModel?.profile?.name.toString()}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      actions: [
        InkWell(
          onTap: () {
            widget.scaffoldKey.currentState?.openDrawer();
          },
          child: SvgPicture.asset(
            'assets/bee.svg',
            height: 21,
            color: Theme.of(context).primaryColor,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 27,
                color: Theme.of(context).primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 5),
                child: Container(
                  height: 9,
                  width: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: lefttorightgradient,
                  ),
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Get.to(() => PremiumwelcomeScreen());
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Image.asset(
                  'assets/Group 48096050.png',
                  height: 25,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Container(
                  height: 9,
                  width: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: lefttorightgradient,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
