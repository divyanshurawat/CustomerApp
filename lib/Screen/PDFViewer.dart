import 'package:flutter/material.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

import '../Helper/Color.dart';



class Brochure extends StatefulWidget {
  @override
  _BrochureState createState() => _BrochureState();
}

class _BrochureState extends State<Brochure> {
  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromAsset('assets/brochure.pdf');

    setState(() => _isLoading = false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: colors.primary,
          title: const Text('My Brochure'),
        ),
        body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(
            document: document,
            lazyLoad: false,
            zoomSteps: 1,

            //uncomment below line to preload all pages
            // lazyLoad: false,
            // uncomment below line to scroll vertically
            // scrollDirection: Axis.vertical,

            //uncomment below code to replace bottom navigation with your own
            /* navigationBuilder:
                      (context, page, totalPages, jumpToPage, animateToPage) {
                    return ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.first_page),
                          onPressed: () {
                            jumpToPage()(page: 0);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            animateToPage(page: page - 2);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            animateToPage(page: page);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.last_page),
                          onPressed: () {
                            jumpToPage(page: totalPages - 1);
                          },
                        ),
                      ],
                    );
                  }, */
          ),
        ),
      )
    ;
  }
}