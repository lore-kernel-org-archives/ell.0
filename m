Content-Type: multipart/mixed; boundary="===============3889422142293788699=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v2 1/5] cipher: Update for current kernel akcipher
 interface
Date: Fri, 10 Jun 2016 09:43:24 -0700
Message-ID: <alpine.OSX.2.20.1606100931520.36509@rpthomps-mobl.wa.intel.com>
In-Reply-To: <CAOq732LJMW7-K3ekQB2AnCKN5EqPfirjHMnQzksmMpm4N2-7Gw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3889422142293788699==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Fri, 10 Jun 2016, Andrzej Zaborowski wrote:

> On 10 June 2016 at 02:38, Andrzej Zaborowski
> <andrew.zaborowski@intel.com> wrote:
>>> +       /*
>>> +        * The RSA signing operation uses the same primitive as
>>> +        * decryption so just call decrypt for now.
>>> +        */
>>
>> This is true for RSA but not for the padding transform so we do need
>> to define ALG_OP_SIGN and ALG_OP_VERIFY and use them.  By the way we
>> may want to have enum l_asymmetric_cipher_type values for both RSA and
>> RSA+padding.
>>
>>>
>>>         result =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
>>>                                                 digest_info,
>>> -                                               key_size, expected_len);
>>> +                                               key_size, key_size);
>>
>> I tihnk we really need to pass expected_len to
>> l_asymmetric_cipher_verify independent of what buffer size we pass to
>> the kernel because it needs to check that the output is the right
>> size, otherwise we may be accepting some invalid signatures (longer
>> than expected_len but starting with the expected bytes) and
>> potentially lowering security.
>
> Sorry, didn't realise your other patch does exactly this, same goes
> for my other comment.
>
> I was thinking that it's simpler to have l_asymmetric_cipher_verify do
> the check as it did before, and not pass the key_size twice.

I thought I had moved the sign/verify changes in to the first cipher =

patch, which would be much clearer. The sign/verify changes don't belong =

in the "add length" patch. I will update the patch set.

Denis suggested removing sign/verify from l_asymmetric_cipher once I =

add the keyctl crypto ops, so it may not matter much in the long run. I'm =

still convincing myself that sign/verify are working - the TLS unit tests =

pass, but that doesn't tell the whole story.

--
Mat Martineau
Intel OTC

--===============3889422142293788699==--

