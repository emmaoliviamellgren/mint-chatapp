import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'landing_page_widget.dart' show LandingPageWidget;
import 'package:flutter/material.dart';

class LandingPageModel extends FlutterFlowModel<LandingPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Slideshow widget.
  PageController? slideshowController;

  int get slideshowCurrentIndex => slideshowController != null &&
          slideshowController!.hasClients &&
          slideshowController!.page != null
      ? slideshowController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
