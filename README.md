# vandana_app

An order management app for [Vandana Mobile Shoppe](https://maps.app.goo.gl/A6MA6BUwm922xjDN7).
Primarily functions as an orderbook for mobile repair orders.

Find images at the bottom.
___
## Features
- Sign in for employees.
- Order creation & state management.
- Track POC for each order.
- Images for orders during creation & delivery.
- Sharing of invoice.
- Updates on sms.

## Tech stuff
- MVC architecture. Modular components.
- Material Design.
- Supabase as backend. Database handles authentication & CRUD operations.
- Bucket storage for media.
- Edge functions for messaging.
___
#### Build instructions

make sure to add `--dart-define=SUPABASE_KEY=your_supabase_anon_key` to run args.

### TODO
- [] OrderService().update method. Only update data that's modified.
- [x] flow for deleting or rejection cancellation. take remarks as input.
- [x] separate delivered flow. Take remarks, mark as paid.
- [x] share order details/invoice screenshot / pdf.
- [x] attach picture with order delivery.
- [x] fetch image in order details if present.
- [X] attach multiple pictures, append one at end of delivered flow.
- [x] share to print.
- [x] Whatsapp message button.
- [x] Single image when creating.
- [x] Reject & cancel dialog box bug.
- [] Multiple images on delivering.
- [] Deliver rework.
- [] Send SMS on created & delivered.
- [] Dark mode. Sync with System.
- [] refactor: move to FutureBuilder for order details & orders list.
___
## Images
![Orders](https://raw.githubusercontent.com/the-loudspeaker/vandana_app/refs/heads/main/showcase/orders.png)

![order details](https://raw.githubusercontent.com/the-loudspeaker/vandana_app/refs/heads/main/showcase/order_details.png)

![Create order](https://raw.githubusercontent.com/the-loudspeaker/vandana_app/refs/heads/main/showcase/create_order.png)

![Edit order](https://raw.githubusercontent.com/the-loudspeaker/vandana_app/refs/heads/main/showcase/edit_order.png)
