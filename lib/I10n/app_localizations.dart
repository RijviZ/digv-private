import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
  ];

  String get appTitle;

  String get app_version;

  String get home;

  String get send_otp;

  String get login;

  String get profile;

  String get darkMode;

  String get language;

  String get booking;

  String get checkOut;

  String get orderHistory;

  String get helpCenter;

  String get splash_welcome;

  String get login_title;

  String get login_subtitle;

  String get otp_title;

  String get home_greeting;

  String get home_search_hint;

  String get location_picker_title;

  String get service_details;

  String get select_technician;

  String get select_date;

  String get select_time;

  String get review_booking;

  String get payment_selection;

  String get active_order;

  String get order_history_title;

  String get order_history_subtitle;

  String get rating_title;

  String get manage_addresses;

  String get refer_earn;

  String get or;

  String get continue_with_google;

  String get by_continuing;

  String get terms_of_service;

  String get privacy_policy;

  String get and;

  String get back;

  String get code_sent_to;

  String get verify_continue;

  String get resend_otp_in;

  String get didnt_receive_code;

  String get resend;

  String get track_your_order;

  String get go_to_home;

  String get booking_confirmed;

  String get booking_requested;

  String get pay_after_service;

  String get upi_paid;

  String get cash_on_delivery;

  String get regular_service;

  String get schedule;

  String get address;

  String get payment;

  String get service;

  String get continue_button;

  String get confirm_booking;

  String get proceed_to_pay;

  String get select_payment_method;

  String get order_summary;

  String get subtotal;

  String get taxes_and_fees;

  String get total;

  String get total_amount;

  String get technician;

  String get rating;

  String get reviews;

  String get add_to_cart;

  String get included;

  String get excluded;

  String get order_tracking;

  String get payment_successful;

  String get cancel_booking_title;

  String get cancel_booking_subtitle;

  String get keep_booking;

  String get yes_cancel;

  String get online_status;

  String get uploading_attachment;

  String get sent_image_attachment;

  String get no_messages_yet;

  String get type_a_message;

  String get service_completed_title;

  String get your_delivery_otp;

  String get share_otp_notice;

  String get otp_warning;

  String get confirm_otp;

  String get live_map_eta;

  String get postpaid_order;

  String get postpaid_banner_desc;

  String get order_progress;

  String get paid;

  String get retry;

  String get appearance;

  String get currently_on;

  String get currently_off;

  String get light;

  String get dark;

  String get lang_notice;

  String get contact_support_title;

  String get edit_profile_title;

  String get faqs_title;

  String get saved_addresses;

  String get saved_cards;

  String get notification_settings_title;

  String get logout;

  String get share_app_title;

  String get first_name;

  String get last_name;

  String get email_address;

  String get phone_number;

  String get save_changes;

  String get add_new_address;

  String get add_new_card;

  String get call_us;

  String get email_us;

  String get whatsapp;

  String get copy_link;

  String get link_copied;

  String get recent_bookings;

  String get total_spent;

  String get account;

  String get preferences;

  String get support;

  String get push_notifications;

  String get app_settings;

  String get email_alerts;

  String get promotional_offers;

  String get tab_home;

  String get tab_orders;

  String get tab_more;

  String get my_orders_title;

  String get active;

  String get upcoming;

  String get past;

  String get cancelled;

  String get notifications_title;

  String get no_notifications;

  String get card_number;

  String get expiry_date;

  String get cvv;

  String get cardholder_name;

  String get welcome_title;

  String get get_started;

  String get continue_btn;

  String get skip;

  String get enable_location;

  String get change_photo;

  String get select_gender;

  String get male;

  String get female;

  String get other;

  String get location_details;

  String get label_hint;

  String get address_line;

  String get city;

  String get state;

  String get postal_code;

  String get get_current_location;

  String get set_default_address;

  String get save_address;

  String get default_badge;

  String get allow_notifications_desc;

  String get notification_types;

  String get upi_ids;

  String get bank_accounts;

  String get set_default_payment_method;

  String get no_saved_cards;

  String get report_an_issue;

  String get popular_topics;

  String get search_help_articles;

  String get order_updates_title;
  String get order_updates_desc;
  String get offers_promotions_title;
  String get offers_promotions_desc;
  String get app_announcements_title;
  String get app_announcements_desc;
  String get chat_messages_title;
  String get chat_messages_desc;

  String get popular_how_to_book;
  String get popular_payment_issues;
  String get popular_reschedule;
  String get popular_cancel;
  String get popular_rate;
  String get popular_change_address;

  String get payments_refunds;
  String get service_technicians;
  String get account_profile;
  String get referral_rewards;
  String get articles_count;

  String get still_need_help;
  String get support_available_247;
  String get live_chat;
  String get avg_response;

  String get contact_channels;
  String get send_message;
  String get your_recent_ticket;
  String get choose_a_channel;
  String get whatsapp_support;
  String get call_support;
  String get email_support;
  String get support_hours;
  String get fastest;
  String get popular;

  String get explore_services;
  String get service_for_you;
  String get verified_technicians_desc;
  String get first_service_offer_title;
  String get new_user_offer_desc;
  String get book_now;
  String get track_order_btn;
  String get active_badge;
  String get bookings_suffix;
  String get read_all;
  String get new_section;
  String get link_upi_id;
  String get add_bank_account;
  String get view_otp_code;
  String get share_otp_technician;

  String get step_created;
  String get step_created_sub;
  String get step_booking_confirmed;
  String get step_booking_confirmed_sub;
  String get step_tech_assigned;
  String get step_on_the_way;
  String get step_arrived;
  String get step_work_started;
  String get step_work_done_otp;
  String get step_completed;

  String get send_message_btn;
  String get your_details;
  String get select_a_subject;
  String get related_order_id_optional;
  String get describe_issue_hint;
  String get attachment_optional;
  String get attach_screenshot_photo;

  String get invite_friends_desc;
  String get how_it_works;
  String get share_code_step;
  String get friend_download_step;
  String get share_invite_now;

  String get live_chat_title;
  String get live_chat_desc;
  String get whatsapp_title;
  String get whatsapp_desc;
  String get call_support_title;
  String get call_support_desc;
  String get email_support_title;
  String get email_support_desc;
  String get support_subtitle;
  String get first_service_offer_sub;
  String get your_referral_code;

  String get promo_refer_earn_title;
  String get promo_refer_earn_sub;
  String get promo_free_inspection_title;
  String get promo_free_inspection_sub;
  String get promo_flash_sale_title;
  String get promo_flash_sale_sub;
  String get regular_service_from;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }
  throw FlutterError('Failed to lookup AppLocalizations for locale "$locale');
}
