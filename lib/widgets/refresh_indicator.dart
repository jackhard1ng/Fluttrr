import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Custom pull-to-refresh wrapper with better UX
class RefreshableList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final Widget? header;
  final Widget? footer;
  final Widget? emptyWidget;
  final bool isLoading;
  final Widget? loadingWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget Function(BuildContext, int)? separatorBuilder;

  const RefreshableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.header,
    this.footer,
    this.emptyWidget,
    this.isLoading = false,
    this.loadingWidget,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.separatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: emptyWidget ?? const _DefaultEmptyWidget(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        controller: controller,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        shrinkWrap: shrinkWrap,
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length + (header != null ? 1 : 0) + (footer != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (header != null && index == 0) {
            return header!;
          }

          final itemIndex = header != null ? index - 1 : index;

          if (footer != null && itemIndex >= items.length) {
            return footer!;
          }

          if (itemIndex >= items.length) return const SizedBox.shrink();

          final item = items[itemIndex];

          if (separatorBuilder != null && itemIndex < items.length - 1) {
            return Column(
              children: [
                itemBuilder(context, item, itemIndex),
                separatorBuilder!(context, itemIndex),
              ],
            );
          }

          return itemBuilder(context, item, itemIndex);
        },
      ),
    );
  }
}

class _DefaultEmptyWidget extends StatelessWidget {
  const _DefaultEmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.grey.withAlpha(128),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nothing here yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pull down to refresh',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pull-to-refresh wrapper for any widget
class PullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primaryBlue,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}

/// Refreshable sliver list for use with CustomScrollView
class RefreshableSliverList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final List<Widget>? slivers;
  final Widget? emptySliver;
  final bool isLoading;

  const RefreshableSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.slivers,
    this.emptySliver,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primaryBlue,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (slivers != null) ...slivers!,
          if (isLoading && items.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              child: emptySliver ?? const _DefaultEmptyWidget(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => itemBuilder(context, items[index], index),
                childCount: items.length,
              ),
            ),
        ],
      ),
    );
  }
}

/// Infinite scroll list with automatic loading
class InfiniteScrollList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onLoadMore;
  final Future<void> Function()? onRefresh;
  final bool hasMore;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final double loadMoreThreshold;

  const InfiniteScrollList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    this.onRefresh,
    this.hasMore = true,
    this.isLoading = false,
    this.loadingWidget,
    this.emptyWidget,
    this.padding,
    this.loadMoreThreshold = 200,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.hasMore) return;

    setState(() => _isLoadingMore = true);
    await widget.onLoadMore();
    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.items.isEmpty) {
      return widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const _DefaultEmptyWidget();
    }

    Widget list = ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );

    if (widget.onRefresh != null) {
      list = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: AppColors.primaryBlue,
        child: list,
      );
    }

    return list;
  }
}
