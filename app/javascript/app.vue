<template>
  <draggable v-model="lists" :options="{group: 'lists'}" class="row dragArea" @end="listMoved">
    <div v-for="(list, index) in lists" class="col-3">
      <h6>{{ list.name }}</h6>
      <hr />

      <draggable v-model="list.cards" :options="{group: 'cards'}" class="dragArea" @change="cardMoved">
        <div v-for="(card, index) in list.cards" class="card card-body mb-3">
          {{ card.name }}
        </div>
      </draggable>

      <div class="card card-body">
        <textarea class="form-control" v-model="messages[list.id]"></textarea>
        <button class="btn btn-primary" @click="newCard(list.id)">New Card</button>
      </div>
    </div>
  </draggable>
</template>

<script>
import draggable from 'vuedraggable';
export default {

  props: ["original_lists"],
  data: function(){
    return {
      messages: {},
      lists: this.original_lists,
    }
  },
  methods: {
    cardMoved: function(event) {
      const evt = event.added || event.moved
      if (evt == undefined) { return }

      const element = evt.element

      const list_index = this.lists.findIndex(list => {
        return list.cards.find(card => {
          return card.id == element.id
        })
      })
      var data = new FormData;
      data.append("card[list_id]", this.lists[list_index].id)
      data.append("card[position]", evt.newIndex + 1)

      Rails.ajax({
        url: `/cards/${element.id}}/move`,
        type: "PATCH",
        data: data,
        dataType: "json"
      })
    },

    listMoved: function(event) {
      var data = new FormData;
      data.append("list[position]", event.newIndex + 1)

      Rails.ajax({
        url: `/lists/${this.lists[event.newIndex].id}/move`,
        type: "PATCH",
        data: data,
        dataType: "json"
      })
    },

    newCard: function(list_id){
      var data = new FormData;
      data.append("card[list_id]", list_id);
      data.append("card[name]", this.messages[list_id])
      var xmessages = this.messages
      Rails.ajax({
        url: "/cards",
        type: "POST",
        data: data,
        dataType: "json",
        success: (data) => {
          const index = this.lists.findIndex(item => item.id == list_id)
          this.lists[index].cards.push(data)
          this.messages[list_id] = undefined
        }
      })
    }
  },
  components: {
    draggable
  },
  created: function(){
    console.log(this.lists[0].cards)
  }

}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}

.dragArea:hover {
  min-height: 20px;
}
</style>
