<template>
  <div class="bg-slate-500 p-4 flex flex-col gap-3">
    <p class="text-slate-300">Номер вопроса: {{ props.question.id }}</p>
    <h1 class="text-slate-100 text-2xl whitespace-pre-wrap">{{ props.question.question }}</h1>
    <div>
      <template v-for="attachment in props.question.attachments">
        <img :src='"/static/attachments/" + attachment' alt="" srcset="" class="w-1/4">
      </template>
    </div>
    <div class="grid gap-1 grid-cols-[repeat(auto-fit,minmax(150px,1fr))]">
      <template v-for="(answer, ind) in shuffled_answers">
        <div class="p-2 text-center w-full min-w-24 flex flex-col justify-center" @click="toggle(ind)"
          :class="[getColor(ind), answered ? '' : 'hover:bg-slate-700 cursor-pointer']">
          <div class="flex gap-1">
            <input type="checkbox" v-model="answers[ind]" disabled>
            <p class="text-slate-100">{{ answer }}</p>
          </div>
        </div>
      </template>
    </div>
    <button v-if="!answered" @click="submitAnswer" class="bg-slate-600 p-2 hover:bg-slate-800">Submit</button>
    <button v-else @click="next" class="bg-slate-600 p-2 hover:bg-slate-800">Next</button>
  </div>
</template>

<script lang="ts" setup>
import { type MultiSelectQuestion } from '~/stores/questions';
const emit = defineEmits<{
  (event: 'answered', is_correct: boolean): void;
}>();

const answers: Ref<boolean[]> = ref([])
const answered = ref(false)
const is_correct = ref(false)

const shuffled_answers = ref<string[]>([])

onMounted(() => {
  reload()
})


function getColor(index: number) {
  if (answered.value) {
    if (isCorrect(shuffled_answers.value[index])) {
      if (answers.value[index]) {
        return "bg-green-600"
      } else {
        return "bg-yellow-600"
      }
    } else {
      if (answers.value[index]) {
        return "bg-red-600"
      } else {
        return "bg-slate-600"
      }
    }
  } else {
    if (answers.value[index]) {
      return 'bg-slate-800'
    } else {
      return 'bg-slate-600'
    }
  }
}
function toggle(index: number) {
  if (answered.value) return
  answers.value[index] = !answers.value[index]
}
function reload() {
  let new_arr = props.question.candidates.slice()
  shuffled_answers.value = shuffleArray(new_arr)
  answers.value = new Array(shuffled_answers.value.length).fill(false)
  answered.value = false
  is_correct.value = false
  console.log("reload")
}

const props = defineProps<{
  question: MultiSelectQuestion
}>()

watchEffect(() => {
  reload()
})

watch(props, () => {
  reload()
})

function isCorrect(answer: string) {
  return props.question.answer.includes(props.question.candidates?.indexOf(answer))
}

function submitAnswer() {
  answered.value = true
  let total_correct = true;
  for (let i = 0; i < shuffled_answers.value.length; i++) {
    if (isCorrect(shuffled_answers.value[i]) != answers.value[i]) {
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