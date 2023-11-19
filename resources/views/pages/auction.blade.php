@extends('layouts.app')

@section('content')
    <div class="content">
        <div class="left-column">
            <h2><div class="underline-text"> {{$auction->name}} </div></h2>
            <div>By: {{ $auction->owner_id }}</div>
            <img src="{{ $auction->image }}" alt="Auction Image">
        </div>
        <div class="right-column">
            <div>Higher Bid: $$</div>
            <div>Bids: _</div>
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
@endsection