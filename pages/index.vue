<template>
  <div class="w-screen min-h-screen flex p-4 bg-slate-900 gap-2 flex-col">
    <div class="w-full max-w-full flex flex-col gap-1">
      <div class="flex justify-between">
        <div>
          <p class="text-slate-100">Correct: {{ correct_count }}</p>
          <p class="text-slate-100">Incorrect: {{ incorrect_count }}</p>
        </div>
        <button class="bg-slate-600 p-2 hover:bg-slate-800" @click="dialog_visible = true">Settings</button>
      </div>
      <component v-bind:is="myComponent" :question="currentQuestion" @answered="answered"></component>
    </div>
    <Dialog v-model:visible="dialog_visible" modal header="Settings" :style="{ width: '25rem' }"
      pt:root="bg-slate-200 rounded p-4" pt:header="flex flex-row w-full justify-between" pt:headeraction="w-max h-max">
      <div class="flex flex-row justify-between">
        <div>
          <div>
            <input id="set1" type="checkbox" v-model="settingsStore.question_types['text']">
            <label for="set1">Type text</label>
          </div>
          <div>
            <input id="set2" type="checkbox" v-model="settingsStore.question_types['select']">
            <label for="set2">Type select</label>
          </div>
          <div>
            <input id="set3" type="checkbox" v-model="settingsStore.question_types['multiple-select']">
            <label for="set3">Type multi-select</label>
          </div>
          <div>
            <input id="set4" type="checkbox" v-model="settingsStore.question_types['order']">
            <label for="set4">Type order</label>
          </div>
          <div>
            <input id="set5" type="checkbox" v-model="settingsStore.question_types['category']">
            <label for="set5">Type category</label>
          </div>
          <div class="mt-4">
            <input id="set6" type="checkbox" v-model="settingsStore.repeat">
            <label for="set6">Repeat not correct</label>
          </div>
        </div>
        <div class="flex flex-col gap-1 mr-4">
          <template v-for="(bin, ind) in settingsStore.questions_bin">
            <div>
              <input :id="'bin' + ind" type="checkbox" v-model="settingsStore.questions_bin[ind]">
              <label :for="'bin' + ind">{{ ind * 10 + 1 }} - {{ (ind+1)*10 + 1 }}</label>
            </div>
          </template>
        </div>
      </div>

    </Dialog>
  </div>
</template>

<script lang="ts" setup>
import CategoryQuestionForm from '~/components/CategoryQuestionForm.vue';
import MultipleSelectQuestionForm from '~/components/MultipleSelectQuestionForm.vue';
import OrderQuestionForm from '~/components/OrderQuestionForm.vue';
import SelectQuestionForm from '~/components/SelectQuestionForm.vue';
import TextQuestionForm from '~/components/TextQuestionForm.vue';
import { useMyQuestionsStore, type Question } from '~/stores/questions';
import { Dialog } from 'primevue';
const currentQuestion: Ref<Question | null> = ref(null)
const currentQuestionId: Ref<number | null> = ref(0)
const questionsStore = useMyQuestionsStore()
const settingsStore = useMySettingsStore()
const toast = useToast()

const correct_count = ref(0)
const incorrect_count = ref(0)

const dialog_visible = ref(false)

const valid_queue: Ref<number[]> = ref([])

const question_forms: { [id: string]: Component } = {
  "text": TextQuestionForm,
  "select": SelectQuestionForm,
  "multiple-select": MultipleSelectQuestionForm,
  "order": OrderQuestionForm,
  "category": CategoryQuestionForm
}

onMounted(() => {
  if(settingsStore.questions_bin.length != Math.ceil(questionsStore.questions.length / 10))
      settingsStore.questions_bin = new Array(Math.ceil(questionsStore.questions.length / 10)).fill(true)
  const question = questionsStore.getNextRandomQuestion([0], {
    "text": true,
    "select": true,
    "multiple-select": true,
    "order": true,
    "category": true
  })
  currentQuestion.value = question!.q
})

const myComponent: Component = computed(() => {
  if (currentQuestion.value == null) {
    return null
  }
  return question_forms[currentQuestion.value.type]
})

function answered(is_correct: boolean) {
  if (is_correct) {
    correct_count.value += 1
    if(currentQuestionId.value != null)
      valid_queue.value.push(currentQuestionId.value)
    if(valid_queue.value.length > 9) {
      valid_queue.value = valid_queue.value.slice(1)
    }
  } else {
    incorrect_count.value += 1
  }
  if(settingsStore.repeat && !is_correct) return
  loadNextQuestion()
}

function generateRange(a: number, b: number) {
  let result = [];
  for (let i = a; i <= b; i++) {
    result.push(i);
  }
  return result;
}


function loadNextQuestion() {
  const question_nums: number[] = []
  for (let i = 0; i < settingsStore.questions_bin.length; i++) {
    if (!settingsStore.questions_bin[i]) continue
    question_nums.push(...generateRange(i * 10, (i + 1) * 10 - 1))
  }
  const question = questionsStore.getNextRandomQuestion(question_nums.filter(q => !valid_queue.value.includes(q)), settingsStore.question_types)
  if (question == null) {
    toast.add({ summary: "Следующий вопрос не найден", severity: "error", detail: "Измените фильтры", life: 3000})
    return
  }
  currentQuestion.value = question.q
  currentQuestionId.value = question.i
}

</script>

<style></style>