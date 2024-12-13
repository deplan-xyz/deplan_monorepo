import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/credit_card_details.dart';
import 'package:subdoor/models/token_amount.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:transparent_image/transparent_image.dart';

final User user = User(
  id: '',
  username: 'John Doe',
  wallet: 'fake_wallet_address_fake_wallet_address',
);

final UserBalance userBalance = UserBalance(
  nativeTokenBalance: TokenAmount(
    amount: '1000000',
    decimals: 6,
    uiAmount: 1,
    uiAmountString: '1',
  ),
  usdcBalance: TokenAmount(
    amount: '1000000',
    decimals: 6,
    uiAmount: 1,
    uiAmountString: '1',
  ),
  bidBalance: 10,
);

final AuctionItem auctionItem = AuctionItem(
  id: '',
  name: 'Test Item',
  originalPrice: 100,
  currentPrice: 50,
  logo: kTransparentImage,
  logoMimeType: 'image/gif',
  status: AuctionStatus.active,
  subscriptionFrequency: SubscriptionFrequency.monthly,
  startsAt: DateTime.now(),
  offerType: OfferType.auction,
);

final CreditCardDetails creditCardDetails = CreditCardDetails(
  id: '',
  cardNumber: '1234 5678 9012 3456',
  expiryDate: '01/25',
  cvv: '123',
  address: '123 Main St',
  city: 'Anytown',
  state: 'CA',
  zip: '12345',
  status: CreditCardStatus.active,
);
