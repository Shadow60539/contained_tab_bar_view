import 'package:contained_tab_bar_view/src/contained_tab_controller.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'enums.dart';
import 'tab_bar_properties.dart';

class ContainedTabBarView extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> views;
  final TabBarProperties tabBarProperties;
  final int initialIndex;
  final Duration duration;
  final Curve curve;
  final void Function(int) onChange;

  ContainedTabBarView({
    Key key,
    this.tabs,
    this.views,
    this.tabBarProperties: TabBarProperties.empty,
    this.initialIndex: 0,
    this.duration,
    this.curve,
    this.onChange,
  })  : assert(tabs != null),
        assert(views != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => ContainedTabBarViewState();
}

class ContainedTabBarViewState extends State<ContainedTabBarView>
    with SingleTickerProviderStateMixin {
  ContainedTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ContainedTabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
      duration: widget.duration,
      curve: widget.curve,
    )..addListener(() => widget.onChange(_controller.index));
  }

  void animateTo(
    int value, {
    Duration duration,
    Curve curve,
  }) =>
      _controller.animateTo(value, duration: duration, curve: curve);

  void next({
    Duration duration,
    Curve curve,
  }) {
    if (_controller.index == _controller.length - 1) {
      return;
    }
    this.animateTo(_controller.index + 1);
  }

  void previous({
    Duration duration,
    Curve curve,
  }) {
    if (_controller.index == 0) {
      return;
    }
    this.animateTo(_controller.index - 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          _buildFlex(constraints),
    );
  }

  Widget _buildFlex(BoxConstraints constraints) {
    if (widget.tabBarProperties.position == TabBarPosition.left ||
        widget.tabBarProperties.position == TabBarPosition.right) {
      return Row(
        crossAxisAlignment: _decideAlignment(widget.tabBarProperties.alignment),
        children: _buildChildren(constraints),
      );
    }
    return Column(
      crossAxisAlignment: _decideAlignment(widget.tabBarProperties.alignment),
      children: _buildChildren(constraints),
    );
  }

  List<Widget> _buildChildren(BoxConstraints constraints) {
    List<Widget> children = [
      Padding(
        padding: widget.tabBarProperties.outerPadding,
        child: _buildTabBar(),
      ),
      _buildTabBarView(constraints),
    ];

    if (widget.tabBarProperties.position == TabBarPosition.bottom ||
        widget.tabBarProperties.position == TabBarPosition.right) {
      return children.reversed.toList();
    }

    return children;
  }

  Widget _buildTabBar() {
    final List<Widget> backgroundStackChildren = [];
    if (widget.tabBarProperties.background != null) {
      backgroundStackChildren.add(widget.tabBarProperties.background);
    }
    backgroundStackChildren.add(
      Positioned.fill(
        child: Padding(
          padding: widget.tabBarProperties.innerPadding,
          child: TabBar(
            controller: _controller,
            tabs: widget.tabs,
            indicator: widget.tabBarProperties.indicator,
            indicatorColor: widget.tabBarProperties.indicatorColor,
            indicatorPadding: widget.tabBarProperties.indicatorPadding,
            indicatorSize: widget.tabBarProperties.indicatorSize,
            indicatorWeight: widget.tabBarProperties.indicatorWeight,
            isScrollable: widget.tabBarProperties.isScrollable,
            labelColor: widget.tabBarProperties.labelColor,
            labelPadding: widget.tabBarProperties.labelPadding,
            labelStyle: widget.tabBarProperties.labelStyle,
            unselectedLabelColor: widget.tabBarProperties.unselectedLabelColor,
            unselectedLabelStyle: widget.tabBarProperties.unselectedLabelStyle,
          ),
        ),
      ),
    );

    final Widget tabBar = SizedBox(
      width: widget.tabBarProperties.width,
      height: widget.tabBarProperties.height,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: backgroundStackChildren,
      ),
    );

    if (widget.tabBarProperties.position == TabBarPosition.left) {
      return Expanded(
        child: Transform.rotate(
          angle: -math.pi / 2,
          child: tabBar,
        ),
      );
    }

    if (widget.tabBarProperties.position == TabBarPosition.right) {
      return Expanded(
        child: Transform.rotate(
          angle: math.pi / 2,
          child: tabBar,
        ),
      );
    }

    return tabBar;
  }

  Widget _buildTabBarView(BoxConstraints constraints) {
    final EdgeInsets outerPadding =
        widget.tabBarProperties.outerPadding.resolve(TextDirection.ltr);
    if (widget.tabBarProperties.position == TabBarPosition.left ||
        widget.tabBarProperties.position == TabBarPosition.right) {
      return Container(
        width: constraints.maxWidth -
            widget.tabBarProperties.height -
            outerPadding.top -
            outerPadding.bottom,
        child: TabBarView(
          controller: _controller,
          children: widget.views,
        ),
      );
    }
    return Container(
      height: constraints.maxHeight -
          widget.tabBarProperties.height -
          outerPadding.top -
          outerPadding.bottom,
      child: TabBarView(
        controller: _controller,
        children: widget.views,
      ),
    );
  }

  CrossAxisAlignment _decideAlignment(TabBarAlignment alignment) {
    switch (alignment) {
      case TabBarAlignment.start:
        return CrossAxisAlignment.start;
      case TabBarAlignment.center:
        return CrossAxisAlignment.center;
      case TabBarAlignment.end:
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.center;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
