import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seiyuu/util/constants.dart';
import 'package:seiyuu/util/database.dart';
import 'package:seiyuu/util/decoration.dart';
import 'package:seiyuu/util/marker_generator.dart';
import 'package:seiyuu/util/seiyuu.dart';
import 'package:seiyuu/widgets/seiyuu_marker.dart';

class SeiyuuMap extends StatefulWidget {
  List<Seiyuu> seiyuuList;

  SeiyuuMap({Key key, @required this.seiyuuList}) : super(key: key);

  @override
  _SeiyuuMapState createState() => _SeiyuuMapState();
}

class _SeiyuuMapState extends State<SeiyuuMap> {
  GoogleMapController mapController;
  Set<Marker> markers;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();

    List<Widget> markerWidgets = createMarkers(widget.seiyuuList);

    MarkerGenerator(markerWidgets, (bitmaps) {
      setState(() {
        //markers = mapBitmapsToMarkers(bitmaps);
        markers = mapBitmapsToMarkers(bitmaps); //tempMarkerSet;
      });
    }).generate(context);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.hybrid,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: Constants.COORDINATES_JAPAN,
        zoom: 4.5,
      ),
      markers: markers,
      /*{
          Marker(
            markerId: MarkerId("1"),
            position: Constants.COORDINATES_JAPAN,
            icon: BitmapDescriptor.defaultMarker,
          ),
        } //seiyuuMarkers,
        */
    );
  }

  List<Widget> createMarkers(List<Seiyuu> seiyuuList) {
    List<Widget> markerList = List<Widget>();

    seiyuuList.forEach((seiyuu) {
      Widget currentMarker = SeiyuuMarker(
        seiyuu: seiyuu,
      ); //Text("temp"); //seiyuu.getMarker();
      markerList.add(currentMarker);
    });

    return markerList;
  }

  Set<Marker> mapBitmapsToMarkers(List<Uint8List> bitmaps) {
    Set<Marker> tempMarkerSet = Set<Marker>();

    print("Bitmaps length: ${bitmaps.length}");

    bitmaps.asMap().forEach((index, byteData) {
      BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData);
      Seiyuu currentSeiyuu = widget.seiyuuList[index];
      currentSeiyuu.printInfo();

      print("Birthplace: ${currentSeiyuu.birthplace.toLatLng().toString()}");

      //create a marker
      //markerId: the english name + the kanji name
      //position: the birthplace as a LatLng variable
      //icon: bitmap data for the custom marker
      Marker marker = Marker(
        markerId:
            MarkerId("${currentSeiyuu.name + '-' + currentSeiyuu.kanjiName}"),
        position:
            currentSeiyuu.birthplace.toLatLng(), //Constants.COORDINATES_JAPAN,
        icon: icon,
      );
      tempMarkerSet.add(marker);
    });

    return tempMarkerSet;
  }
}
