<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Bid;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
class BidController extends Controller
{
    public function create(Request $request, $id)
    {
      $user = User::find($id);
      $this->authorize('bid', $user);
      
      $bid = new Bid;
      $bid->user_id = Auth::user()->id;
      $bid->auction_id = $id;
      $bid->amount = $request->input('amount');
      $bid->save();
      return redirect('auctions/'.$id);
    }

    public function showCreateForm($auction_id)
    {
      return view('pages.createBid', ['id' => $auction_id]);
    }
    

}
