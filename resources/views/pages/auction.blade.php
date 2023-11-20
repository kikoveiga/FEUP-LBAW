@extends('layouts.app')

@section('content')
    <div class="content">
        <div class="left-column">
            <h2><div class="underline-text"> {{$auction->name}} </div></h2>
            <?php $user = \App\Http\Controllers\UserController::returnUser($auction->owner_id); ?>
            <div>Auctioneer: <a href="{{route('user', ['id' => $user->id])}}">{{ $user->name }}</a></div>
            <img src="{{ $auction->image }}" alt="Auction Image">
        </div>
        <div class="right-column">
            <div> Starting Price: {{ $auction->starting_price }}€</div>
            <div>Highest Bid:
            @if (!count($auction->bids))
                    No bids yet
            @else
                <?php $user = \App\Http\Controllers\UserController::returnUser($auction->bids->sortByDesc('amount')->first()->user_id); ?>
                {{ $auction->bids->sortByDesc('amount')->first()->amount}}€ by <a href="{{route('user', ['id' => $user->id])}}">{{ $user->name }}</a>
            @endif
                
            </div>
            <div>Bids: {{ count($auction->bids) }}

            </div>
            <button class="button button-outline"><a href="{{ route('createBidForm', ['id' => $auction->id]) }}">Place Bid</a></button>
            <form method="POST" action="{{ route('followAuctions', ['id' => $auction->id]) }}">
                {{ csrf_field() }}
                <button class="button button-outline" type="submit">Follow Auction</button>
            </form>
        </div>
        <div class="bottom-content">
            <h2><div class="underline-text">Item Overview</div></h2>
            <div>{{ $auction->description }}</div>
            <h2><div class="underline-text">Auction Details</div></h2>
            <div>This auction started on {{ $auction->start_t }}</div>
            <div>This auction will close on {{ $auction->end_t }}</div>
        </div>
        <div class="edit-delete-buttons">
            <button class="button button-outline"><a href="{{ route('editAuctionForm', ['id' => $auction->id]) }}">Edit</a></button>
            <button class="button button-outline"><a href="{{ route('deleteAuction', ['id' => $auction->id]) }}">Delete</a></button>
        </div>
    </div>
    {{-- if authenticated --}}
    @if (Auth::check())

    {{-- if user is not following --}}
    @if (\App\Http\Controllers\AuctionSaveController::exists(Auth::user()->id, $auction->id) == false)
    <form method="POST" action="{{ route('followAuctions', ['id' => $auction->id]) }}">
        {{ csrf_field() }}
    <button class="button button-outline" type = sumbit>Follow Auction</button>
    </form>
    @endif
    
    {{-- if user is following --}}
    @if (\App\Http\Controllers\AuctionSaveController::exists(Auth::user()->id, $auction->id) == true)
    <form method="POST" action="{{ route('unfollowAuctions', ['id' => $auction->id]) }}">
        {{ csrf_field() }}
    <button class="button button-outline" type = sumbit>Unfollow Auction</button>
    </form>
    @endif

    {{-- if user is not owner --}}
    @if ($auction->owner_id != Auth::user()->id)
    <button class="button button-outline"><a href="{{ route('createBidForm', ['id' => $auction->id]) }}">Place Bid</a></button>
    @endif 

    {{-- if user is owner --}}
    @if ($auction->owner_id == Auth::user()->id)
    <button class="button button-outline"><a href="{{ route('editAuctionForm', ['id' => $auction->id]) }}">Edit </a></button>
    <button class="button button-outline"><a href="{{ route('deleteAuction', ['id' => $auction->id]) }}">Delete </a></button>
    @endif
    @endif
@endsection