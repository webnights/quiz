<template>
  <div class="bg-slate-500 p-4 flex flex-col gap-1" @keypress="enter">
    <p class="text-slate-300">Номер вопроса: {{props.question.id}}</p>
    <h1 class="text-slate-100 text-2xl whitespace-pre-wrap">{{props.question.question}}</h1>
    <p class="text-slate-300 text-1xl whitespace-pre-wrap">Перечислите в порядке правильного ответа (разделитель - пробел)</p>
    <h2 class="text-slate-100 text-1xl whitespace-pre-wrap">{{questionString}}</h2>
    <div>
      <template v-for="attachment in props.question.attachments" :key="attachment">
        <img :src='"/static/attachments/" + attachment' alt="" srcset="" class="w-1/4">
      </template>
    </div>
    <div class="flex gap-4 justify-between">
      <input type="text" v-model="answer_text" :disabled="answered" class="bg-slate-600 p-2 flex-grow">
    </div>
    <button v-if="!answered" @click="submitAnswer"  class="bg-slate-600 p-2 hover:bg-slate-800">Submit</button>
    <button v-else @click="next" class="bg-slate-600 p-2 hover:bg-slate-800">Next</button>
    <p v-if="answered" :class="is_correct ? 'text-green-500' : 'text-red-500'">Answer: {{right_answer}}</p>
  </div>
</template>

<script lang="ts" setup>
import { type OrderQuestion, type Question } from '~/stores/questions';

const emit = defineEmits<{
  (event: 'answered', is_correct: boolean): void;
}>();

onMounted(() => {
  reload()
})


const answer_text = ref('')
const answered = ref(false)
const is_correct = ref(false)
const shuffled_answers = ref<string[]>([])

const right_answer = computed(() => {
  let answers = []
  for (let i = 0; i < props.question.answer.length; i++) {
    answers.push(shuffled_answers.value.indexOf(props.question.answer[i]) + 1)
  }
  return answers.join(" ")
})

const questionString = computed(() => {
  let new_arr = shuffled_answers.value.slice()
  for (let i = 0; i < new_arr.length; i++) {
    new_arr[i] = (i + 1) + ". " + new_arr[i]
  }
  return new_arr.join("\n")
})

const props = defineProps<{
  question: OrderQuestion
}>()

watch(props, () => {
  reload()
})

function submitAnswer() {
  answered.value = true
  is_correct.value = right_answer.value.toString().toLowerCase() === answer_text.value.toString().toLowerCase().trim()
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
  let new_arr = props.question.answer.slice()
  shuffled_answers.value = shuffleArray(new_arr)
}

</script>

<style></style>