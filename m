Content-Type: multipart/mixed; boundary="===============7863642618355058765=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH 0/2] Make some ELL headers completely self-contained.
Date: Thu, 09 Mar 2017 10:23:58 -0800
Message-ID: <CAPyD+=BXU+re2-SRRXM4i_Yz5KRB4R-fHbVHqHA8qyHxsQ0BKQ@mail.gmail.com>
In-Reply-To: <6a4f0746-d693-0495-bc51-70e07529dab8@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7863642618355058765==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Wed, Mar 8, 2017 at 1:34 PM, Denis Kenzior <denkenz@gmail.com> wrote:
>
> On 03/08/2017 02:29 PM, Ossama Othman wrote:
>
>> These patches address some compile-time errors encountered when
>> attempting to use functions and macros declared in installed ELL
>> headers.  The headers in question were not completely self-contained.
>>
>> Ossama Othman (2):
>>   main: Fixed missing uint32_t typedef error
>>   log: Fixed missing L_STRINGIFY macro definition
>>
>>
> Both applied.  Though I wonder why you're not including ell/ell.h and
> including these headers individually.


Honestly, I had not noticed that header until you mentioned it.  Now I see
that the ELL examples include that header, too.  I'll use it instead.
Thanks for correcting my usage.  :)

-Ossama

--===============7863642618355058765==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9Imx0ciI+SGkgRGVuaXMsPGRpdiBjbGFzcz0iZ21haWxfZXh0cmEiPjxicj48ZGl2
IGNsYXNzPSJnbWFpbF9xdW90ZSI+T24gV2VkLCBNYXIgOCwgMjAxNyBhdCAxOjM0IFBNLCBEZW5p
cyBLZW56aW9yIDxzcGFuIGRpcj0ibHRyIj4mbHQ7PGEgaHJlZj0ibWFpbHRvOmRlbmtlbnpAZ21h
aWwuY29tIiB0YXJnZXQ9Il9ibGFuayI+ZGVua2VuekBnbWFpbC5jb208L2E+Jmd0Ozwvc3Bhbj4g
d3JvdGU6PGJsb2NrcXVvdGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0ibWFyZ2luOjAgMCAw
IC44ZXg7Ym9yZGVyLWxlZnQ6MXB4ICNjY2Mgc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+PHNwYW4g
Y2xhc3M9IiI+Ck9uIDAzLzA4LzIwMTcgMDI6MjkgUE0sIE9zc2FtYSBPdGhtYW4gd3JvdGU6PGJy
Pgo8YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhl
eDtib3JkZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4KVGhlc2UgcGF0
Y2hlcyBhZGRyZXNzIHNvbWUgY29tcGlsZS10aW1lIGVycm9ycyBlbmNvdW50ZXJlZCB3aGVuPGJy
PgphdHRlbXB0aW5nIHRvIHVzZSBmdW5jdGlvbnMgYW5kIG1hY3JvcyBkZWNsYXJlZCBpbiBpbnN0
YWxsZWQgRUxMPGJyPgpoZWFkZXJzLsKgIFRoZSBoZWFkZXJzIGluIHF1ZXN0aW9uIHdlcmUgbm90
IGNvbXBsZXRlbHkgc2VsZi1jb250YWluZWQuPGJyPgo8YnI+Ck9zc2FtYSBPdGhtYW4gKDIpOjxi
cj4KwqAgbWFpbjogRml4ZWQgbWlzc2luZyB1aW50MzJfdCB0eXBlZGVmIGVycm9yPGJyPgrCoCBs
b2c6IEZpeGVkIG1pc3NpbmcgTF9TVFJJTkdJRlkgbWFjcm8gZGVmaW5pdGlvbjxicj4KPGJyPgo8
L2Jsb2NrcXVvdGU+Cjxicj48L3NwYW4+CkJvdGggYXBwbGllZC7CoCBUaG91Z2ggSSB3b25kZXIg
d2h5IHlvdSYjMzk7cmUgbm90IGluY2x1ZGluZyBlbGwvZWxsLmggYW5kIGluY2x1ZGluZyB0aGVz
ZSBoZWFkZXJzIGluZGl2aWR1YWxseS48L2Jsb2NrcXVvdGU+PGRpdj48YnI+PC9kaXY+PGRpdj5I
b25lc3RseSwgSSBoYWQgbm90IG5vdGljZWQgdGhhdCBoZWFkZXIgdW50aWwgeW91IG1lbnRpb25l
ZCBpdC7CoCBOb3cgSSBzZWUgdGhhdCB0aGUgRUxMIGV4YW1wbGVzIGluY2x1ZGUgdGhhdCBoZWFk
ZXIsIHRvby7CoCBJJiMzOTtsbCB1c2UgaXQgaW5zdGVhZC7CoCBUaGFua3MgZm9yIGNvcnJlY3Rp
bmcgbXkgdXNhZ2UuIMKgOik8L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2Pi1Pc3NhbWE8L2Rpdj48
ZGl2Pjxicj48L2Rpdj48L2Rpdj48L2Rpdj48L2Rpdj4K

--===============7863642618355058765==--

