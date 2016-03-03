Content-Type: multipart/mixed; boundary="===============8401652913722693796=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] key: Add basic keystore support
Date: Thu, 03 Mar 2016 17:42:58 -0600
Message-ID: <56D8CC02.1000704@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1603031011210.922@mjmartin-mac01.wa.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8401652913722693796==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >> Are there kernel keyctl internal enumerations for key types as well?
>> E.g. how do we know that a certificate loaded by keyctl is a private
>> key vs a public key?
>>
>
> Asymmetric keys have a "subtype", but there's only one right now (x509).
> When an asymmetric key is created, it has a list of parsers to attempt,
> and a successful parser will set the subtype appropriately. After the
> key is created, KEYCTL_DESCRIBE will return a string which contains the
> key type and subtype information.
>
> User keys are just a blob.
>
> This leads me to think that the type should be retrieved from the kernel
> dynamically, similar to how the size is handled.
>

My thinking as well.  Last I looked the keyctl 'types' were a bit weird. =

  So we may need to do some additional work here.

>
> My current DH implementation in the kernel has separate keyctl commands
> for deriving the public key and shared secret (with the internal
> implementation sharing the common math and key handling), but I'm going
> to change that to just one KEYCTL_DH_COMPUTE command. The user then gets
> the public key by passing in the generator key id, and the shared secret
> by passing in the peer public key.

Yep, I think that's a good way of doing it.  Lets see what the kernel =

guys think :)

>
>>
>> What key type do we use for prime and generator?
>> Do we really need to make the distinction between private / public
>> types?  If the types are dropped above, not much of value is lost...
>
> On the kernel side, they're all "user" keys
> (prime/generator/public/private), since the asymmetric type only handles
> x509 format.
>
> There isn't much value in tracking the key types for DH. The motivation
> has more to do with asymmetric ciphers. When creating a new key in the
> kernel, a type string must be specified ("user", "asymmetric", etc.),
> and the enumerations would map to the appropriate kernel key type
> string. However, it's sufficient to have more general types like
> L_KEY_RAW and L_KEY_ASYMMETRIC. Sound like a better approach?
>

Yep, I think so.  We can also postpone adding the key type for now until =

our understanding of the asymmetric key types and key type extraction =

from the kernel are a bit less fuzzy.

Regards,
-Denis


--===============8401652913722693796==--

