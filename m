Content-Type: multipart/mixed; boundary="===============8225203611825011084=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH v3] unit: Added generic netlink family unit test
Date: Tue, 21 Mar 2017 13:46:56 -0700
Message-ID: <CAPyD+=DgS-45GB1vR0qkbm8jBo7Y3UBV2Vi_30Mn9S11+uea2w@mail.gmail.com>
In-Reply-To: <76176f19-79d0-3a54-c723-feae1a6c4565@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8225203611825011084==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, Mar 21, 2017 at 1:42 PM, Denis Kenzior <denkenz@gmail.com> wrote:
>
> On 03/21/2017 02:57 PM, Ossama Othman wrote:
>
>> ---
>>  Makefile.am             |  3 ++
>>  unit/test-genl-family.c | 99 ++++++++++++++++++++++++++++++
>> +++++++++++++++++++
>>
>
> Do you want to add this test to unit/test-genl instead?  That test is a
> no-op at this point anyway.


Okay, that's fine with me.


> +static void do_debug(const char *str, void *user_data)
>> +{
>> +       const char *prefix =3D user_data;
>> +
>> +       l_info("%s%s", prefix, str);
>> +}
>> +
>>
>
> I know test-genl does this, but...  generally our unit tests don't print
> anything.  Do you really need this?


Not at all.  I was just trying to be consistent with test-genl.

+       return vanished_called ? 0 : -1;
>>
>
> This is probably okay, but it might be better to use asserts, especially
> if more tests are added to this unit file in the future.
>

Okay, I'll go back to returning 0 and rely on an assert() instead.

Thanks Denis!
-Ossama

--===============8225203611825011084==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9Imx0ciI+SGkgRGVuaXMsPGRpdiBjbGFzcz0iZ21haWxfZXh0cmEiPjxicj48ZGl2
IGNsYXNzPSJnbWFpbF9xdW90ZSI+T24gVHVlLCBNYXIgMjEsIDIwMTcgYXQgMTo0MiBQTSwgRGVu
aXMgS2VuemlvciA8c3BhbiBkaXI9Imx0ciI+Jmx0OzxhIGhyZWY9Im1haWx0bzpkZW5rZW56QGdt
YWlsLmNvbSIgdGFyZ2V0PSJfYmxhbmsiPmRlbmtlbnpAZ21haWwuY29tPC9hPiZndDs8L3NwYW4+
IHdyb3RlOjxibG9ja3F1b3RlIGNsYXNzPSJnbWFpbF9xdW90ZSIgc3R5bGU9Im1hcmdpbjowIDAg
MCAuOGV4O2JvcmRlci1sZWZ0OjFweCAjY2NjIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPjxzcGFu
IGNsYXNzPSIiPgpPbiAwMy8yMS8yMDE3IDAyOjU3IFBNLCBPc3NhbWEgT3RobWFuIHdyb3RlOjxi
cj4KPGJsb2NrcXVvdGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44
ZXg7Ym9yZGVyLWxlZnQ6MXB4ICNjY2Mgc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+Ci0tLTxicj4K
wqBNYWtlZmlsZS5hbcKgIMKgIMKgIMKgIMKgIMKgIMKgfMKgIDMgKys8YnI+CsKgdW5pdC90ZXN0
LWdlbmwtZmFtaWx5LmMgfCA5OSArKysrKysrKysrKysrKysrKysrKysrKysrKysrKys8d2JyPisr
KysrKysrKysrKysrKysrKys8YnI+CjwvYmxvY2txdW90ZT4KPGJyPjwvc3Bhbj4KRG8geW91IHdh
bnQgdG8gYWRkIHRoaXMgdGVzdCB0byB1bml0L3Rlc3QtZ2VubCBpbnN0ZWFkP8KgIFRoYXQgdGVz
dCBpcyBhIG5vLW9wIGF0IHRoaXMgcG9pbnQgYW55d2F5LjwvYmxvY2txdW90ZT48ZGl2Pjxicj48
L2Rpdj48ZGl2Pk9rYXksIHRoYXQmIzM5O3MgZmluZSB3aXRoIG1lLjwvZGl2PjxkaXY+wqA8L2Rp
dj48YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhl
eDtib3JkZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij48ZGl2PjxkaXYg
Y2xhc3M9Img1Ij48YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46
MCAwIDAgLjhleDtib3JkZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4K
K3N0YXRpYyB2b2lkIGRvX2RlYnVnKGNvbnN0IGNoYXIgKnN0ciwgdm9pZCAqdXNlcl9kYXRhKTxi
cj4KK3s8YnI+CivCoCDCoCDCoCDCoGNvbnN0IGNoYXIgKnByZWZpeCA9IHVzZXJfZGF0YTs8YnI+
Cis8YnI+CivCoCDCoCDCoCDCoGxfaW5mbygmcXVvdDslcyVzJnF1b3Q7LCBwcmVmaXgsIHN0cik7
PGJyPgorfTxicj4KKzxicj4KPC9ibG9ja3F1b3RlPgo8YnI+PC9kaXY+PC9kaXY+Ckkga25vdyB0
ZXN0LWdlbmwgZG9lcyB0aGlzLCBidXQuLi7CoCBnZW5lcmFsbHkgb3VyIHVuaXQgdGVzdHMgZG9u
JiMzOTt0IHByaW50IGFueXRoaW5nLsKgIERvIHlvdSByZWFsbHkgbmVlZCB0aGlzPzwvYmxvY2tx
dW90ZT48ZGl2Pjxicj48L2Rpdj48ZGl2Pk5vdCBhdCBhbGwuwqAgSSB3YXMganVzdCB0cnlpbmcg
dG8gYmUgY29uc2lzdGVudCB3aXRoIHRlc3QtZ2VubC48L2Rpdj48ZGl2Pjxicj48L2Rpdj48Ymxv
Y2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDtib3Jk
ZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij48ZGl2PjxkaXYgY2xhc3M9
Img1Ij48YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAg
LjhleDtib3JkZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4KK8KgIMKg
IMKgIMKgcmV0dXJuIHZhbmlzaGVkX2NhbGxlZCA/IDAgOiAtMTs8YnI+CjwvYmxvY2txdW90ZT4K
PGJyPjwvZGl2PjwvZGl2PgpUaGlzIGlzIHByb2JhYmx5IG9rYXksIGJ1dCBpdCBtaWdodCBiZSBi
ZXR0ZXIgdG8gdXNlIGFzc2VydHMsIGVzcGVjaWFsbHkgaWYgbW9yZSB0ZXN0cyBhcmUgYWRkZWQg
dG8gdGhpcyB1bml0IGZpbGUgaW4gdGhlIGZ1dHVyZS48YnI+PC9ibG9ja3F1b3RlPjxkaXY+PGJy
PjwvZGl2PjxkaXY+T2theSwgSSYjMzk7bGwgZ28gYmFjayB0byByZXR1cm5pbmcgMCBhbmQgcmVs
eSBvbiBhbiBhc3NlcnQoKSBpbnN0ZWFkLjwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+VGhhbmtz
IERlbmlzITwvZGl2PjxkaXY+LU9zc2FtYTwvZGl2PjxkaXY+PGJyPjwvZGl2PjwvZGl2PjwvZGl2
PjwvZGl2Pgo=

--===============8225203611825011084==--

