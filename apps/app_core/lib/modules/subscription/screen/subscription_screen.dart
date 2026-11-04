import 'dart:async';

import 'package:app_core/app/helpers/logger_helper.dart';
import 'package:app_core/core/presentation/widgets/app_snackbar.dart';
import 'package:app_core/modules/subscription/cubit/subscription_cubit.dart';
import 'package:app_core/modules/subscription/repository/subscription_repository.dart';
import 'package:app_core/modules/subscription/subscription_utils/subscripion_utils.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SubscriptionScreen extends StatelessWidget implements AutoRouteWrapper {
  const SubscriptionScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SubscriptionRepository(),
      child: BlocProvider(
        create: (context) {
          final cubit = SubscriptionCubit(
            RepositoryProvider.of<SubscriptionRepository>(context),
            context,
          );
          unawaited(cubit.getPlans(context, SubscriptionUtils.subscriptionProductId));
          return cubit;
        },
        child: this,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        if (context.read<SubscriptionCubit>().state.status ==
            SubscriptionStateStatus.purchaseLoading) {
          showAppSnackbar(context, 'Please wait until we verify your subscription');
          return true;
        } else {
          return false;
        }
      },
      child: BlocListener<SubscriptionCubit, SubscriptionState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == SubscriptionStateStatus.purchaseSuccess) {
            showAppSnackbar(context, 'Purchase Successfully');
            unawaited(context.read<SubscriptionCubit>().getAndSetActivePlanOfUser());
          }
          flog('status in listen of subscription: ${state.status}');
        },
        child: AppScaffold(
          appBar: const CustomAppBar(title: 'Purchase Plans', centerTitle: true),
          body: SingleChildScrollView(
            child: Column(
              spacing: Insets.xsmall8,
              children: [
                _PurchasePlanCard(
                  label: 'Consumable',
                  iconData: Icons.diamond,
                  description: 'Basic Gem purchase',
                  onTap: () async {
                    await context.read<SubscriptionCubit>().purchaseCredit(
                      context,
                      SubscriptionUtils.subscriptionProductId[0],
                    );
                  },
                ),
                _PurchasePlanCard(
                  label: 'Non-Renewing Subscription',
                  iconData: Icons.currency_bitcoin,
                  description: '3-Month Exam Prep Access',
                  onTap: () async {
                    await context.read<SubscriptionCubit>().purchaseSubscription(
                      context,
                      SubscriptionUtils.subscriptionProductId[2],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchasePlanCard extends StatelessWidget {
  const _PurchasePlanCard({
    required this.label,
    required this.iconData,
    required this.onTap,
    required this.description,
  });

  final String label;
  final IconData iconData;
  final VoidCallback onTap;
  final String description;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(50),
          borderRadius: BorderRadius.circular(AppBorderRadius.small8),
        ),
        margin: const EdgeInsets.all(Insets.xsmall8),
        padding: const EdgeInsets.all(Insets.large24),
        child: Column(
          children: [
            Row(
              spacing: Insets.medium16,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.L(text: label, maxLines: 2),
                Icon(iconData, size: Insets.xxlarge40),
              ],
            ),
            Row(children: [AppText.sSemiBold(text: description)]),
          ],
        ),
      ),
    );
  }
}
