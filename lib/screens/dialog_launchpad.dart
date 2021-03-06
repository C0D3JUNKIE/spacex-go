import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:latlong/latlong.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/launchpad.dart';
import '../util/colors.dart';
import '../util/url.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/row_item.dart';
import '../widgets/separator.dart';

/// LAUNCHPAD DIALOG VIEW
/// This view displays information about a specific launchpad,
/// where rockets get rocketed to the sky...
class LaunchpadDialog extends StatelessWidget {
  static final List<String> _menu = [
    'spacex.other.menu.wikipedia',
  ];

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<LaunchpadModel>(
      builder: (context, child, model) => Scaffold(
            body: CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.3,
                floating: false,
                pinned: true,
                actions: <Widget>[
                  PopupMenuButton<String>(
                    itemBuilder: (_) => _menu
                        .map((string) => PopupMenuItem(
                              value: string,
                              child: Text(
                                FlutterI18n.translate(context, string),
                              ),
                            ))
                        .toList(),
                    onSelected: (_) async =>
                        await FlutterWebBrowser.openWebPage(
                          url: model.launchpad.url,
                          androidToolbarColor: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(model.name),
                  background: model.isLoading
                      ? LoadingIndicator()
                      : FlutterMap(
                          options: MapOptions(
                            center: LatLng(
                              model.launchpad.coordinates[0],
                              model.launchpad.coordinates[1],
                            ),
                            zoom: 6.0,
                            minZoom: 5.0,
                            maxZoom: 10.0,
                          ),
                          layers: <LayerOptions>[
                            TileLayerOptions(
                              urlTemplate: Url.mapView,
                              subdomains: ['a', 'b', 'c', 'd'],
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            MarkerLayerOptions(markers: [
                              Marker(
                                width: 45.0,
                                height: 45.0,
                                point: LatLng(
                                  model.launchpad.coordinates[0],
                                  model.launchpad.coordinates[1],
                                ),
                                builder: (_) => const Icon(
                                      Icons.location_on,
                                      color: locationPin,
                                      size: 45.0,
                                    ),
                              )
                            ])
                          ],
                        ),
                ),
              ),
              model.isLoading
                  ? SliverFillRemaining(child: LoadingIndicator())
                  : SliverToBoxAdapter(child: _buildBody())
            ]),
          ),
    );
  }

  Widget _buildBody() {
    return ScopedModelDescendant<LaunchpadModel>(
      builder: (context, child, model) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: <Widget>[
              Text(
                model.launchpad.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.title,
              ),
              Separator.spacer(),
              RowItem.textRow(
                context,
                FlutterI18n.translate(
                  context,
                  'spacex.dialog.pad.status',
                ),
                model.launchpad.getStatus,
              ),
              Separator.spacer(),
              RowItem.textRow(
                context,
                FlutterI18n.translate(
                  context,
                  'spacex.dialog.pad.location',
                ),
                model.launchpad.location,
              ),
              Separator.spacer(),
              RowItem.textRow(
                context,
                FlutterI18n.translate(
                  context,
                  'spacex.dialog.pad.state',
                ),
                model.launchpad.state,
              ),
              Separator.spacer(),
              RowItem.textRow(
                context,
                FlutterI18n.translate(
                  context,
                  'spacex.dialog.pad.coordinates',
                ),
                model.launchpad.getCoordinates,
              ),
              Separator.spacer(),
              RowItem.textRow(
                context,
                FlutterI18n.translate(
                  context,
                  'spacex.dialog.pad.launches_successful',
                ),
                model.launchpad.getSuccessfulLaunches,
              ),
              Separator.divider(),
              Text(
                model.launchpad.details,
                textAlign: TextAlign.justify,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Theme.of(context).textTheme.caption.color),
              ),
            ]),
          ),
    );
  }
}
