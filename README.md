# vandana_app

An order management app for [Vandana Mobile shoppe](https://maps.app.goo.gl/A6MA6BUwm922xjDN7) <a href="https://maps.app.goo.gl/A6MA6BUwm922xjDN7" target="_blank">Vandana Mobile Shoppe</a>.
The app primarily functions as a orderbook for mobile repair orders.

Find images at the bottom.
___
## Features
- Sign in for employees.
- Order creation & state management.
- Track POC for each order.
- Images for orders.
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
- OrderService().update method. Only update data that's modified.
- flow for deleting or rejection cancellation. take remarks as input.
- separate delivered flow. Take remarks, mark as paid.
- share order details/invoice screenshot / pdf.
- attach picture with order.
- attach multiple pictures, append one at end of delivered flow.
- Send SMS on created & delivered.
- Dark mode. Sync with System.
___
## Images
![Orders](https://raw.githubusercontent.com/the-loudspeaker/vandana_app/refs/heads/main/showcase/orders.png)

![order details](https://raw.githubusercontent.com/the-loudspeaker/vandana_app/refs/heads/main/showcase/order_details.png)

![Create order](https://raw.githubusercontent.com/the-loudspeaker/vandana_app/refs/heads/main/showcase/create_order.png)

![Edit order](https://raw.githubusercontent.com/the-loudspeaker/vandana_app/refs/heads/main/showcase/edit_order.png)
