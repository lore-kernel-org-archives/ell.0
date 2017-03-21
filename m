Content-Type: multipart/mixed; boundary="===============5231475974055345794=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH] unit: Added generic netlink family unit test
Date: Tue, 21 Mar 2017 12:34:56 -0700
Message-ID: <CAPyD+=BGzOS4u3y=81vm0j6Wp6Bdf_FXKYJkSUvVauzbuGX80w@mail.gmail.com>
In-Reply-To: <1490124644-10103-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5231475974055345794==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Mar 21, 2017 at 12:30 PM, Ossama Othman <ossama.othman@intel.com>
wrote:
>
> +static void family_vanished(void *user_data)
> +{
> +       bool *vanished_called =3D user_data;
> +
> +       *vanished_called =3D true;
> +       l_main_quit();
>

I just noticed this extraneous l_main_quit() call.  It doesn't affect the
unit test result but I'll resend the patch with it removed.


> +}
> +
> +static void idle_handler(struct l_idle *idle, void *user_data)
> +{
> +       static int count =3D 0;
> +
> +       /*
> +        * Allow the main loop to iterate at least once.  Otherwise
> +        * the generic netlink watches won't be called.
> +        */
> +       if (count++ =3D=3D 1)
> +               l_main_quit();
> +}


Thanks,
-Ossama

--===============5231475974055345794==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9Imx0ciI+SGksPGJyPjxkaXYgY2xhc3M9ImdtYWlsX2V4dHJhIj48YnI+PGRpdiBj
bGFzcz0iZ21haWxfcXVvdGUiPk9uIFR1ZSwgTWFyIDIxLCAyMDE3IGF0IDEyOjMwIFBNLCBPc3Nh
bWEgT3RobWFuIDxzcGFuIGRpcj0ibHRyIj4mbHQ7PGEgaHJlZj0ibWFpbHRvOm9zc2FtYS5vdGht
YW5AaW50ZWwuY29tIiB0YXJnZXQ9Il9ibGFuayI+b3NzYW1hLm90aG1hbkBpbnRlbC5jb208L2E+
Jmd0Ozwvc3Bhbj4gd3JvdGU6PGJsb2NrcXVvdGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0i
bWFyZ2luOjAgMCAwIC44ZXg7Ym9yZGVyLWxlZnQ6MXB4ICNjY2Mgc29saWQ7cGFkZGluZy1sZWZ0
OjFleCI+CitzdGF0aWMgdm9pZCBmYW1pbHlfdmFuaXNoZWQodm9pZCAqdXNlcl9kYXRhKTxicj4K
K3s8YnI+CivCoCDCoCDCoCDCoGJvb2wgKnZhbmlzaGVkX2NhbGxlZCA9IHVzZXJfZGF0YTs8YnI+
Cis8YnI+CivCoCDCoCDCoCDCoCp2YW5pc2hlZF9jYWxsZWQgPSB0cnVlOzxicj4KK8KgIMKgIMKg
IMKgbF9tYWluX3F1aXQoKTs8YnI+PC9ibG9ja3F1b3RlPjxkaXY+PGJyPjwvZGl2PjxkaXY+SSBq
dXN0IG5vdGljZWQgdGhpcyBleHRyYW5lb3VzIGxfbWFpbl9xdWl0KCkgY2FsbC7CoCBJdCBkb2Vz
biYjMzk7dCBhZmZlY3QgdGhlIHVuaXQgdGVzdCByZXN1bHQgYnV0IEkmIzM5O2xsIHJlc2VuZCB0
aGUgcGF0Y2ggd2l0aCBpdCByZW1vdmVkLjwvZGl2PjxkaXY+wqA8L2Rpdj48YmxvY2txdW90ZSBj
bGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDtib3JkZXItbGVmdDox
cHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4KK308YnI+Cis8YnI+CitzdGF0aWMgdm9p
ZCBpZGxlX2hhbmRsZXIoc3RydWN0IGxfaWRsZSAqaWRsZSwgdm9pZCAqdXNlcl9kYXRhKTxicj4K
K3s8YnI+CivCoCDCoCDCoCDCoHN0YXRpYyBpbnQgY291bnQgPSAwOzxicj4KKzxicj4KK8KgIMKg
IMKgIMKgLyo8YnI+CivCoCDCoCDCoCDCoCAqIEFsbG93IHRoZSBtYWluIGxvb3AgdG8gaXRlcmF0
ZSBhdCBsZWFzdCBvbmNlLsKgIE90aGVyd2lzZTxicj4KK8KgIMKgIMKgIMKgICogdGhlIGdlbmVy
aWMgbmV0bGluayB3YXRjaGVzIHdvbiYjMzk7dCBiZSBjYWxsZWQuPGJyPgorwqAgwqAgwqAgwqAg
Ki88YnI+CivCoCDCoCDCoCDCoGlmIChjb3VudCsrID09IDEpPGJyPgorwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqBsX21haW5fcXVpdCgpOzxicj4KK308L2Jsb2NrcXVvdGU+PGRpdj48YnI+PC9kaXY+
PGRpdj5UaGFua3MsPC9kaXY+PGRpdj4tT3NzYW1hPC9kaXY+PGRpdj7CoDwvZGl2PjwvZGl2Pjwv
ZGl2PjwvZGl2Pgo=

--===============5231475974055345794==--

