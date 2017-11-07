#import <SDCAlertView/UIViewController+Extension.h>

@interface UIViewController (SDCAlertViewPrivate)

+ (nullable UIViewController *)sdc_topViewController NS_EXTENSION_UNAVAILABLE_IOS("");
+ (nullable UIViewController *)sdc_topViewControllerPresentedFrom:(nullable UIViewController *)controller NS_EXTENSION_UNAVAILABLE_IOS("");

@end


@implementation UIViewController (SDCAlertView)

+ (nullable UIViewController *)sdc_topViewController {
    return [self sdc_topViewControllerPresentedFrom:nil];
}

+ (nullable UIViewController *)sdc_topViewControllerPresentedFrom:(nullable UIViewController *)controller {
    UIViewController *viewController = controller ?: [UIApplication sharedApplication].keyWindow.rootViewController;

    if ([viewController isKindOfClass:[UINavigationController class]] && ((UINavigationController *)viewController).viewControllers.count > 0) {
        return [self sdc_topViewControllerPresentedFrom:((UINavigationController *)viewController).viewControllers.lastObject];
    }

    if ([viewController isKindOfClass:[UITabBarController class]] && ((UITabBarController *)viewController).selectedViewController) {
        return [self sdc_topViewControllerPresentedFrom:((UITabBarController *)viewController).selectedViewController];
    }

    if (viewController.presentedViewController != nil) {
        return [self sdc_topViewControllerPresentedFrom:viewController.presentedViewController];
    }

    return viewController;
}

- (void)sdc_present {
    [self sdc_presentAnimated:YES completion:nil];
}

- (void)sdc_presentAnimated:(BOOL)animated completion:(void (^_Nullable)(void))completion {
    [[[UIViewController class] sdc_topViewController] presentViewController:self animated:animated completion:completion];
}

@end
