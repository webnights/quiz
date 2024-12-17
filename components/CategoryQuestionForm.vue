<template>
  <div class="bg-slate-500 p-4 flex flex-col gap-3">
    <p class="text-slate-300">Номер вопроса: {{ props.question.id }}</p>
    <h1 class="text-slate-100 text-2xl whitespace-pre-wrap">{{ props.question.question }}</h1>
    <div>
      <template v-for="attachment in props.question.attachments">
        <img :src='"/static/attachments/" + attachment' alt="" srcset="" class="w-1/4">
      </template>
    </div>
    <div class="grid gap-1 w-fit max-w-full" :class="answered ? 'grid-cols-3' : 'grid-cols-2'">
      <template v-for="(answer, ind) in shuffled_answers">
        <p class="text-slate-100">{{ answer }}</p>
        <select v-model="answers[ind]" :disabled="answered"
        class="text-slate-950"
          :class="answered ? (isCorrect(answer, answers[ind]) ? 'bg-green-500' : 'bg-red-500') : 'bg-slate-100'">
          <option v-for="(candidate, ind) in props.question.categories" :value="candidate">
            {{ candidate }}</option>
        </select>
        <p v-if="answered" class="text-slate-100">{{
          props.question.categories[props.question.answer[props.question.candidates.indexOf(answer)]] }}</p>
      </template>
    </div>
    <button v-if="!answered" @click="submitAnswer" class="bg-slate-600 p-2 hover:bg-slate-800">Submit</button>
    <button v-else @click="next" class="bg-slate-600 p-2 hover:bg-slate-800">Next</button>
  </div>
</template>

<script lang="ts" setup>
import { type CategoryQuestion, type Question } from '~/stores/questions';

const emit = defineEmits<{
  (event: 'answered', is_correct: boolean): void;
}>();

const answers: Ref<string[]> = ref([])
const answered = ref(false)
const is_correct = ref(false)

const shuffled_answers = ref<string[]>([])
onMounted(() => {
  reload()
})


function reload() {
  let new_arr = props.question.candidates.slice()
  shuffleArray(new_arr)
  shuffled_answers.value = new_arr
  answers.value = new Array(shuffled_answers.value.length).fill("")
  answered.value = false
  is_correct.value = false
  console.log("reload")
}

const props = defineProps<{
  question: CategoryQuestion
}>()

watch(props, () => {
  reload()
})

function isCorrect(answer: string, category: string) {
  return props.question.answer[props.question.candidates?.indexOf(answer)] == props.question.categories?.indexOf(category)
}

function submitAnswer() {
  answered.value = true
  let total_correct = true;
  for (let i = 0; i < shuffled_answers.value.length; i++) {
    if (!isCorrect(shuffled_answers.value[i], answers.value[i])) {
      total_correct = false
      break
    }
  }
  is_correct.value = total_correct
}

function next() {
  emit('answered', is_correct.value)
  reload()
}
</script>

<style></style>