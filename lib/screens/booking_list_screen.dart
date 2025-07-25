import 'package:flutter/material.dart';
import 'package:flutter_api_request_simpler/models/booking_status_model.dart';
import 'package:flutter_api_request_simpler/network_utils/api_controller.dart';
import 'package:flutter_api_request_simpler/network_utils/api_request_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../config.dart';
import '../models/service_response.dart';

List<StatusModel>? cachedStatus;

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  ApiRequestController<List<ServiceData>> serviceController =
      ApiRequestController();
  ApiRequestController<List<StatusModel>> bookingStatusController =
      ApiRequestController();

  String selectedStatus = '';

  Map<String, String> get getQueryParam => {
    'per_page': perPageItem.toString(),
    'status': selectedStatus.validate() == '' ? '1' : selectedStatus.validate(),
  };

  @override
  void dispose() {
    serviceController.dispose();
    bookingStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApiRequestWidget<List<ServiceData>>(
        controller: serviceController,
        endpoint: 'service-list',
        queryParams: getQueryParam,
        enablePagination: true,
        fromJson: (json) =>
            (json as List).map((e) => ServiceData.fromJson(e)).toList(),
        onSuccess: (response, scrollController) {
          return AnimatedScrollView(
            controller: scrollController,
            onNextPage: () {
              serviceController.nextPage();
            },
            onSwipeRefresh: () {
              serviceController.refresh();
              return Future.value(true);
            },
            children: [
              ApiRequestWidget(
                controller: bookingStatusController,
                endpoint: 'booking-status',
                fromJson: (json) =>
                    (json as List).map((e) => StatusModel.fromJson(e)).toList(),
                initialData: cachedStatus,
                useInitialDataOnly: true,
                onSuccess: (response, scrollController) {
                  return SizedBox(
                    height: 50,
                    child: AnimatedListView(
                      shrinkWrap: true,
                      itemCount: response.length,
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        StatusModel data = response[index];

                        return Container(
                          child: Text(data.label.validate()),
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(8),
                        ).onTap(() {
                          selectedStatus = data.value.validate();

                          serviceController.setQueryParams(getQueryParam);
                          serviceController.refresh();
                        }, borderRadius: radius());
                      },
                    ),
                  );
                },
              ),
              30.height,
              AnimatedListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (p0, index) {
                  ServiceData data = response[index];

                  return ListTile(
                    leading: Image.network(
                      data.provider_image.validate(),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(30),
                    title: Text('${data.id} - ${data.name.validate()}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(data.attchments.validate().length, (
                          index,
                        ) {
                          return Image.network(
                            data.attchments![index].validate(),
                            height: 150,
                            fit: BoxFit.cover,
                          ).cornerRadiusWithClipRRect(8);
                        }),
                        16.height,
                        ReadMoreText(data.description.validate()),
                      ],
                    ),
                  );
                },
                itemCount: response.length,
              ),
            ],
          );
        },
      ),
    );
  }
}
