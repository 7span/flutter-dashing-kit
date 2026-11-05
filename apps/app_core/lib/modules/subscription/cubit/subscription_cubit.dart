// ignore_for_file: avoid_single_cascade_in_expression_statements
import 'dart:async';
import 'dart:io';

import 'package:app_core/app/helpers/injection.dart';
import 'package:app_core/app/helpers/logger_helper.dart';
import 'package:app_core/modules/subscription/model/subscription_model.dart';
import 'package:app_core/modules/subscription/repository/subscription_repository.dart';
import 'package:app_subscription/app_subscription.dart';
import 'package:app_subscription/app_subscription_api.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this.repository, this.context)
    : super(const SubscriptionState()) {
    repository.init(context);
    unawaited(listenToPurchaseStream(context));
  }

  final SubscriptionRepository repository;
  final BuildContext context;
  final CustomInAppPurchase _inAppPurchase = getIt<CustomInAppPurchase>();

  void togglePlanType(PlanType planType) {
    emit(state.copyWith(planType: planType));
  }

  Future<void> listenToPurchaseStream(BuildContext context) async {
    _inAppPurchase.getPurchaseStream().listen((purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        await _inAppPurchase.completePendingPurchases();
        Platform.isIOS
              ? await repository
                  .verifyPaymentForIOS(
                    purchaseToken:
                        purchaseDetails.verificationData.serverVerificationData,
                  )
                  .run()
              : await repository
                  .verifyPaymentForAndroid(
                    productId: purchaseDetails.productID,
                    purchaseToken:
                        purchaseDetails.verificationData.serverVerificationData,
                  )
                  .run()
          ..fold(
            (l) => emit(
              state.copyWith(status: SubscriptionStateStatus.purchaseFailed),
            ),
            (r) => emit(
              state.copyWith(status: SubscriptionStateStatus.purchaseSuccess),
            ),
          );
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        emit(state.copyWith(status: SubscriptionStateStatus.purchaseCancelled));
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        flog('purchase details in the error state: ${purchaseDetails.error}');
        emit(state.copyWith(status: SubscriptionStateStatus.purchaseFailed));
      } else if (purchaseDetails.status == PurchaseStatus.restored) {
        emit(state.copyWith(status: SubscriptionStateStatus.purchaseRestored));
      }
    });
  }

  Future<void> getPlans(BuildContext context, List<String> productIds) async {
    emit(state.copyWith(status: SubscriptionStateStatus.loading));
    final getPlansEither = await repository.getPlans(context, productIds).run();
    getPlansEither.fold(
      (_) =>
          emit(state.copyWith(status: SubscriptionStateStatus.getPlansError)),
      (plans) {
        flog('plans are these : ${plans.length} , ${plans.first.id}');
        emit(
          state.copyWith(
            plans: plans,
            status: SubscriptionStateStatus.plansLoaded,
          ),
        );
      },
    );
  }

  /// Purchase non-consumable products or subscriptions
  Future<void> purchaseSubscription(BuildContext context, String planId) async {
    emit(state.copyWith(status: SubscriptionStateStatus.purchaseLoading));

    final purchaseSubscriptionEither =
        await repository
            .buyNonConsumable(
              productDetails: state.plans.firstWhere(
                (plan) => plan.id == planId,
              ),
              oldProductId: state.currentPlan?.plan?.productId,
              userSubscription: UserSubscription(
                oldSubscriptionId: state.currentPlan?.plan?.productId,
                subscriptionPurchaseToken:
                    state.currentPlan?.subscriptionPurchaseToken,
                subscriptionTransactionId:
                    state.currentPlan?.subscriptionTransactionId,
              ),
            )
            .run();

    purchaseSubscriptionEither.fold(
      (l) {
        flog('Purchase subscription failed: $l');
        emit(state.copyWith(status: SubscriptionStateStatus.purchaseFailed));
      },
      (r) {
        flog('buy non consumable succeeded');
        // emit(state.copyWith(status: SubscriptionStateStatus.purchaseSuccess));
      },
    );
  }

  /// This is used to display the price of all plans in the card
  ProductDetails getCreditPlan(String productId) {
    return state.plans.firstWhere((plan) => plan.id == productId);
  }

  /// To buy consumable products
  Future<void> purchaseCredit(BuildContext context, String productId) async {
    final plan = getCreditPlan(productId);
    final purchaseCreditsEither =
        await repository.buyConsumable(context, plan).run();

    purchaseCreditsEither.fold(
      (l) =>
          emit(state.copyWith(status: SubscriptionStateStatus.purchaseFailed)),
      (r) {
        debugPrint('Buy credits succeeded');
        // emit(state.copyWith(status: SubscriptionStateStatus.purchaseSuccess));
      },
    );
  }

  /// This is used for getting the current selected plan of the user as well as to display the
  /// price of all plans in the card
  ProductDetails getCurrentPlan(PlanType planType) {
    switch (planType) {
      case PlanType.basic:
        return state.plans.firstWhere((plan) => plan.id == 'basic_plan');
      case PlanType.premium:
        return state.plans.firstWhere(
          (plan) => plan.id == 'yearly_subscription',
        );
    }
  }

  Future<void> getAndSetActivePlanOfUser() async {
    final getUserPlanEither = await repository.getActiveSubscription().run();
    await getUserPlanEither.fold(
      (l) {
        flog('error in getting current plan: $l');
      },
      (r) async {
        emit(state.copyWith(currentPlan: r));
        return r;
      },
    );
    // await getIt<HiveService>().setSubscriptionPlan(plan!).run();
  }

  @override
  Future<void> close() async {
    flog('subscription cubit on close');
    await repository.dispose(context);
    return super.close();
  }
}
