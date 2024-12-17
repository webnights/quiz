<template>
  <div class="bg-slate-500 p-4 flex flex-col gap-1" @keypress="enter">
    <p class="text-slate-300">Номер вопроса: {{props.question.id}}</p>
    <h1 class="text-slate-100 text-2xl whitespace-pre-wrap">{{props.question.question}}</h1>
    <div>
      <template v-for="attachment in props.question.attachments">
        <img :src='"/static/attachments/" + attachment' alt="" srcset="" class="w-1/4">
      </template>
    </div>
    <div class="flex gap-4 justify-between">
      <input type="text" v-model="answer_text" :disabled="answered" class="bg-slate-600 p-2 flex-grow" tabindex="0"/>
    </div>
    <button v-if="!answered" @click="submitAnswer"  class="bg-slate-600 p-2 hover:bg-slate-800">Submit</button>
    <button v-else @click="next" class="bg-slate-600 p-2 hover:bg-slate-800" tabindex="0">Next</button>
    <p v-if="answered" :class="is_correct ? 'text-green-500' : 'text-red-500'">Answer: {{props.question.answer}}</p>
  </div>
</template>

<script lang="ts" setup>
import { type Question } from '~/stores/questions';

const emit = defineEmits<{
  (event: 'answered', is_correct: boolean): void;
}>();

const answer_text = ref('')
const answered = ref(false)
const is_correct = ref(false)

const props = defineProps<{
  question: Question
}>()

function submitAnswer() {
  answered.value = true
  is_correct.value = props.question.answer.toString().toLowerCase() === answer_text.value.toString().toLowerCase().trim()
}

function enter(event: KeyboardEvent) {
  if(event.key !== 'Enter') return
  if(answered.value){
    next()
  } else {
    submitAnswer()
  }
}

function next(){
  emit('answered', is_correct.value)
  reload()
}

function reload(){
  answered.value = false
  answer_text.value = ''
  is_correct.value = false
}

</script>

<style></style>