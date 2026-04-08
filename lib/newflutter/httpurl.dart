import 'dart:ui';

const app_url = 'http://16.163.9.142:9587/cbf-admin/';
const ANDROID_KEY_STORE =
    "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAynQ0hllSV5OUBKtAGtKRL4jOQRKnue8QwYK/yS77ld4ZpQy0ozTise5n8JuuuuHvczHEKnghvlfltGjd/Po17qcow+oqr64xtSdhNECUwKYOK1JFjqwwwvsNbcbhcyocUDDSFhd00KXt3zMN3J2EgklgFmhVxunEfC8qy7GGAbMh+DbZo7Pzkuw96rltvKs/ckVr3YNrIUVtWnThmhviEuDMMXCXRnzG85k9Ji8ARqnmYll4Kvdcuy83IkT5sfBJNlr9Q5h5BjXGtS2hGRWKN2gFmLjVLdErcx+CZUHac8gRqL5AWKNi2do7mu+sYj3GtoMfMpUllu1SNobj2OVmGQIDAQAB";
const PRIVATE =
    "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDKdDSGWVJXk5QEq0Aa0pEviM5BEqe57xDBgr/JLvuV3hmlDLSjNOKx7mfwm6664e9zMcQqeCG+V+W0aN38+jXupyjD6iqvrjG1J2E0QJTApg4rUkWOrDDC+w1txuFzKhxQMNIWF3TQpe3fMw3cnYSCSWAWaFXG6cR8LyrLsYYBsyH4Ntmjs/OS7D3quW28qz9yRWvdg2shRW1adOGaG+IS4MwxcJdGfMbzmT0mLwBGqeZiWXgq91y7LzciRPmx8Ek2Wv1DmHkGNca1LaEZFYo3aAWYuNUt0StzH4JlQdpzyBGovkBYo2LZ2jua76xiPca2gx8ylSWW7VI2huPY5WYZAgMBAAECggEAG1hez9a4vIN+drL60aSnX5hG45s1dHPJ+5lBdlcWPEPniteQforiI85j06fzjeJ+iTyrlmDrjd4pdJjFgyn4pueFJhE2+su4gxNymbAvZ2YGe+t84ax4WZ23TqCSSw/hCyPM/JbmfFgtLPykXqwX/dETXXNyQo/Irk1gpmqwAwKFdYWluw7hrFd2U8F+uuQ/d7Br2nCzHP3NQ2Nbv8gEj0r8DaTZivlLhXaFC7bT3RLtHDAjfAI48wLP+F6hojoBPR5cxm6FwbmbT03Jo6dtdlG1CDf8lwKVqooKyr9olZxkQ30BIHoath58qKJ/+0PUIikChJvOgYNDMOsqkWYSEQKBgQDxRvRaThMgJ1wDgjJeCaCr+ONUwaONT3EfchFnPSYJccOyZeYyu5tLLYwWJ8Zf5K+6ePl/+G+a/e66WHYYKRdxjg2n4hjss/Rud68XSUFNskEm4/ZxLZA+ly+N0PFbkEk4fgZ7680WDm8njXzcMTEMEVbg6gTLR/ZQo4wpfhgfnwKBgQDWzsi1OJMnisOg7GhzLE23zK0Qbq93oA93okS7ZnPteMEnbVnUpD+TLUtua2ILgVyNVwDj1VvFSig5XtgxcdZQGxF43yWoxX2zI289xLFiaaTdQyHNpVpa9D0TU9EmtgFH/em5KU1btfuZHCoIXG9r7NyFJgYkBC800K80JkO/RwKBgQC8auepmezvoC0IBGWm8CfMBIorByjc0pwJrX+Pur34hCIKL+9L0Rwd4kzShG8zNZhRq+VTnUQyqnkChtB6X6SSJhfd8f/64TFSDx7ptWhM75ZXc5Bho+5QIqqdOf0xvwSfHDOeFG/M+KqvHZvTLIsb3HKXI8looiLlqEJtqK3YCwKBgG3QiQscQR6V8izyrvMyUwkDufYMn+eoDEA81KZ5WgqtERH29VWgImA7Z7SrcRQwrgAT2oCfMqtJnga2Vg/xAn8xV11Ttwzw6bILC3Ooeoa1O3NiPoXDYs3cztxynRoNMdp8FGB0nPelsVo068gaeVvTW2k2Zy1Cdl+pz+f5J+lBAoGBAIM/4/sxhweRfDweSX5hWT7PQbntRo9g0NeLQGeSFOhmegErW7Eke6L8yPOlXNsGJcTbJXoLSJ8nko7yYqe1GIj/HamPltFmizO2e0ZQWCdlsPJhKqNZvqPwdNiV4q2c+lsq1sya4jmW5KLh2SbPIxemsk8TxpMJ0iwOPEpAg4OK";

const String smsSendUrl = app_url + '/yql/vvqqb';
//const String login1Url = app_url + '/login';
const String login1Url = app_url + '/app/login';
const String veriloginUrl = app_url + '/login/google/verify';
const String collectOrderUrl =
    app_url + '/collection/v2/distributeOrderGet/list';
const String userBaseInfoUrl = app_url + '/collection/v2/user/base/info';
const String userUrlInfoUrl = app_url + '/collection/v2/user/base/userUrlInfo';
const String emergencyContactsUrl =
    app_url + '/collection/v2/emergency/contacts/list';
const String addressbookContactsUrl =
    app_url + '/collection/v2/addressbook/contacts/list';
const String followlist = app_url + '/collection/v2/commentGet/list';
const String ocrurl = app_url + '/collection/v2/user/base/userOcrUrl';
const String caseQueryUrl = app_url + '/collection/v2/case/query';
const String phoneRecordAddUrl = app_url + '/collection/v2/phone/record/add';
const String repaymentLinkUrl = app_url + '/collection/v2/repayment/link/';
const String appLinkUrl = app_url + '/collection/v2/app/link/';
const String utrrecord = app_url + '/utr';
const String utrFileUploadUrl = app_url + '/file/upload';
const String extensionConfirmUrl = app_url + '/pay/confirm/payExtension';
const String extensionbackUrl = app_url + '/pay/cancel/extensionV3';
const String closeUrl = app_url + '/pay/confirm/repaymentV2';
const String decuinfoUrl = app_url + '/liquidation/v2/{LoanId}/repayment/info';
const String deductionUrl = app_url + '/liquidation/deduct/submit';
const String ruteUrl = app_url + '/getRouters';
const String pythonUrl = app_url + '/bizStats/general/queryPythonV2';

const String verifycodeUrl = app_url + '/dvum/xiwtlw/goqy/god';

const String configUrl = app_url + '/vupg/qnyq/xml';

const String loanNewUserUrl = app_url + '/spmyz/dakb/azlqsj';

const String fileUploadUrl = app_url + '/aamq/pif/iyeka/rua';

const String userSaveDeviceUrl = app_url + '/hqy/jftms/vlcd/knnwf';

const String loanPaymentUrl = app_url + '/vsrjh/nkexvt/mixanz';

const String GetABUrl = app_url + '/plkvm/xegery/sui/sji/ymhsqp';

const String pointPutUrl = app_url + '/jho/sswi/pzy/sxyeqv';

const String adjustThirdUrl = app_url + '/yga/mmx/zjpion/rvnh/caja';

const String showDialogUrl = app_url + '/fxw/dqusao/jgqosa/yht/lgy';

const String saveCallInfoUrl = app_url + '/rsqt/wks';
const String scoreUrl = app_url + '/uqrn/tdli/nyghmz/nmvl/kuy';

const String termsConditionsUrl =
    'https://docs.google.com/document/d/1QWMa0-50HKeqhgInMuw0C9iBBiEid6SB6bUsF9yh4Bg/edit?usp=sharing';

const String privacyPolicyUrl =
    'https://docs.google.com/document/d/1yJm3toIFB6afuji4mcqgUEKzPer9YsNCUOrh58tfzdA/edit?usp=sharing';

const String aboutUsUrl =
    'https://docs.google.com/document/d/15VM5UsW6E_KkXO_qVDm2qHAJmRtFE6pbuFkM-8fqyLc/edit?usp=sharing';

const String app_id = '';

const String adjust_key = 'lkm0esw6ub5s';

const String app_versionCode = '1';

const String app_appCode = 'RupeeGauge';

const String app_appName = 'RupeeGauge';

const String app_emial = 'easyemisite@outlook.com';

const Color main_color = Color(0xff112038);

const Color text_color = Color(0xff856CF5);

const Color mes_color = Color(0xff515B70);
