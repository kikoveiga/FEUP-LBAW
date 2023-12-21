@extends('layouts.app')

@section('title', 'Owned Bids')

@section('content')
<div class="bids-list">
    @foreach ($bids as $bid)
        <div class="bid-card">
          @include('partials.bidCard', ['bid' => $bid])
        </div>
    @endforeach
</div>
@endsection