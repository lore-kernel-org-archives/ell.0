Content-Type: multipart/mixed; boundary="===============1829448500504219843=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: Re: [PATCH v2 1/3] watchlist: added watchlist functionality
Date: Wed, 31 Oct 2018 13:52:56 -0700
Message-ID: <224aed54a774b0a667477d3178e92a83d4334eb7.camel@linux.intel.com>
In-Reply-To: <alpine.OSX.2.21.1810311329490.15001@pgaurav-mobl.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1829448500504219843==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> > +
> > +void __watchlist_prune_stale(struct l_watchlist *watchlist);
> =

> Should this be in the public header?

Yeah.. I meant to inquire about this. Its needed for the macros below
so it does need to be available as a public API, but its not meant to
be called directly. Not sure if ELL has anything else like this. Any
suggestions?

> =

> Thanks,
> Mat
> =

> =

> > +
> > +#define L_WATCHLIST_NOTIFY(watchlist, type, args...)		=

> > 	\
> > +	do {								=

> > \
> > +		const struct l_queue_entry *entry =3D			\
> > +				l_queue_get_entries((watchlist)-
> > >items);\
> > +									=

> > \
> > +		(watchlist)->in_notify =3D true;				=

> > \
> > +		for (; entry; entry =3D entry->next) {			=

> > \
> > +			struct l_watchlist_item *item =3D entry->data;	=

> > \
> > +			type t =3D item->notify;				=

> > \
> > +			if (item->id =3D=3D 0)				\
> > +				continue;				\
> > +			t(args, item->notify_data);			\
> > +		}							\
> > +		(watchlist)->in_notify =3D false;				=

> > \
> > +		if ((watchlist)->stale_items)				=

> > \
> > +			__watchlist_prune_stale(watchlist);		\
> > +	} while	(false)							=

> > \
> > +
> > +#define L_WATCHLIST_NOTIFY_MATCHES(watchlist, match, match_data,
> > type, args...) \
> > +	do {								=

> > \
> > +		const struct l_queue_entry *entry =3D			\
> > +				l_queue_get_entries((watchlist)-
> > >items);\
> > +									=

> > \
> > +		(watchlist)->in_notify =3D true;				=

> > \
> > +		for (; entry; entry =3D entry->next) {			=

> > \
> > +			struct l_watchlist_item *item =3D entry->data;	=

> > \
> > +			type t =3D item->notify;				=

> > \
> > +									=

> > \
> > +			if (item->id =3D=3D 0)				\
> > +				continue;				\
> > +			if (!match(item, match_data))			=

> > \
> > +				continue;				\
> > +									=

> > \
> > +			t(args, item->notify_data);			\
> > +		}							\
> > +		(watchlist)->in_notify =3D false;				=

> > \
> > +		if ((watchlist)->stale_items)				=

> > \
> > +			__watchlist_prune_stale(watchlist);		\
> > +	} while	(false)
> > +
> > +#define L_WATCHLIST_NOTIFY_NO_ARGS(watchlist, type)		=

> > 	\
> > +	do {								=

> > \
> > +		const struct l_queue_entry *entry =3D			\
> > +				l_queue_get_entries((watchlist)-
> > >items);\
> > +									=

> > \
> > +		(watchlist)->in_notify =3D true;				=

> > \
> > +		for (; entry; entry =3D entry->next) {			=

> > \
> > +			struct l_watchlist_item *item =3D entry->data;	=

> > \
> > +			type t =3D item->notify;				=

> > \
> > +			if (item->id =3D=3D 0)				\
> > +				continue;				\
> > +			t(item->notify_data);			\
> > +		}							\
> > +		(watchlist)->in_notify =3D false;				=

> > \
> > +		if ((watchlist)->stale_items)				=

> > \
> > +			__watchlist_prune_stale(watchlist);		\
> > +	} while	(false)
> > +
> > +#ifdef __cplusplus
> > +}
> > +#endif
> > +
> > +#endif /* __ELL_WATCHLIST_H */
> > \ No newline at end of file
> > -- =

> > 2.17.1
> > =

> > _______________________________________________
> > ell mailing list
> > ell(a)lists.01.org
> > https://lists.01.org/mailman/listinfo/ell
> > =

> =

> --
> Mat Martineau
> Intel OTC

Thanks,
James


--===============1829448500504219843==--

